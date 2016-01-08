class FormStructuresController < ApplicationController
  skip_before_filter :header_authenticate!, only: :export
  before_filter :form_authenticate!, only: :export

  def response_query
    structure_record = FormBuilderLookup.find_structure(current_user, params[:id])
    @export_checkbox_horizontal = false
    response_json = do_response_query(current_user, structure_record)
    AuditLogger.view(current_user, structure_record)
    render json: response_json
  end

  def export
    structure_record = FormBuilderLookup.find_structure(current_user, params[:id])
    download_options = JSON.parse(params[:downloadOptions])
    @export_checkbox_horizontal = download_options["checkboxHorizontal"]
    use_codes = download_options["useCodes"]
    use_phi = download_options["includePhi"]
    empty_answer_code = download_options["emptyAnswerCode"]
    conditionally_blocked_code = download_options["conditionallyBlockedCode"]
    response_json = do_response_query(current_user, structure_record, false, use_codes, use_phi, empty_answer_code, conditionally_blocked_code)
    export_headers = []
    response_json[:gridHeader].each do |ques|
      export_headers.push(ques[:value])
    end
    csv_str = CsvTableConverter.convert(response_json[:grid], export_headers)
    proj_id = structure_record.project_id
    phi_file_string = (use_phi) ? "-includes-identifying-information" : ""
    time = Time.now.strftime("%m/%d/%yT%I:%M:%S")
    proj_name = Project.find_by(:id => proj_id).name
    #TODO
    file_name = "#{proj_name}-#{structure_record.name}#{phi_file_string}-#{time}.csv"
    AuditLogger.export(current_user, structure_record, file_name, export_headers)
    cookies[:labcompass_download_file] = "success"
    send_data csv_str, type: "text/csv", filename: file_name
  end

  def existing_subjects
    existing_ids = []
    i = 0
    FormResponse.where(form_structure_id: params[:id]).pluck(:subject_id).uniq.each do |subject_id|
      existing_ids[i] = subject_id
      i = i + 1
    end
    render json: {existing_ids: existing_ids}
  end

  def set_response_secondary_ids
    secondary_id = params[:secondary_id]
    if secondary_id == nil or secondary_id == ""
      raise PayloadException.validation_error({name: "Please enter a name"})
    end
    form_id = params[:id]
    structure = FormStructure.find(form_id)
    unless Permissions.user_can_enter_form_responses_for_form_structure?(current_user, structure)
      raise PayloadException.access_denied "You do not have access to edit responses for this form"
    end
    structure.form_responses.each do |response|
      response.secondary_id = secondary_id
      response.save!
    end
    payload = FormStructureSerializer.serialize(current_user, structure, true)
    render json: {formStructure: payload}
  end

  def get_max_instances
    structure = FormStructure.find(params[:id])
    unless Permissions.user_can_enter_form_responses_for_form_structure?(current_user, structure)
      raise PayloadException.access_denied "You do not have access to edit responses for this form"
    end
    num_instances = FormResponseLookup.get_max_instances_in_form(params[:id])
    render json: {numInstances: num_instances}
  end

#  def create_response
#    structure_record = FormBuilderLookup.find_structure(current_user, params[:id])
#    form_response = FormResponseBuilder.build(current_user, structure_record, params[:subject_id])
#    payload = FormResponseSerializer.serialize(current_user, form_response)
#    render json: {formResponse: payload}
#  end

  def show
    structure_record = FormBuilderLookup.find_structure(current_user, params[:id])
    payload = FormStructureSerializer.serialize(current_user, structure_record, true)
    render json: {formStructure: payload}
  end

  def update
    structure_record = FormBuilderLookup.find_structure(current_user, params[:id])
    updated_structure = FormStructureUpdater.update(current_user, structure_record, params[:form_structure])
    payload = FormStructureSerializer.serialize(current_user, updated_structure, false)
    render json: {formStructure: payload}
  end

  def destroy
    structure_record = FormBuilderLookup.find_structure(current_user, params[:id])
    project = structure_record.project
    FormStructureDestroyer.destroy(current_user, structure_record)
    payload = ProjectSerializer.serialize(current_user, project, true)
    render json: {project: payload}
  end

  # def export
  #   structure_record = FormBuilderLookup.find_structure(current_user, params[:id])
  #   table_generator = FormResponsesTableGeneratorBuilder.build(params[:@include_phi] == "true", current_user, structure_record)
  #   AuditLogger.export current_user, structure_record, table_generator
  #   csv_data = ExportCsvGenerator.generate(table_generator, structure_record.form_responses)
  #   cookies[:labcompass_download_file] = "success"
  #   send_data csv_data, type: "text/csv", filename: "#{table_generator.table_name}.csv"
  # end

#  def get_errors
#    structure = FormBuilderLookup.find_structure(current_user, params[:id])
#    form_response = FormRecordCreator.new_response(params[:subject_id], structure, [])
#    updated_response = FormResponseUpdater.get_errors(current_user, form_response, params[:form_response])
#    render json: { formResponse: FormResponseSerializer.serialize(current_user, updated_response) }
#  end

  private
  def do_response_query(user, form, include_percent=true, use_codes=false, use_phi=true, empty_code="", blocked_code="\u200D")
    GC.start
    team = get_team_member_rs(form.project_id, user.id)
    can_phi = (team.view_personally_identifiable_answers and use_phi)
    if include_percent
      grid_header = [{value: "Subject ID" ,type: "text"},
                     {value: "Total Filled %", type: "numericalrange"}]
    else
      grid_header = [{value: "Subject ID" ,type: "text"}]
    end

    all_responses = get_form_responses_rs(form)
    response_hash = {}
    ordered_subjects = []
    subject_date_hash = {}

    grid_data = []
    total_questions = 0
    @question_to_option_hash = {}
    form.form_questions.each do |question|
      if question.personally_identifiable and (!can_phi or !use_phi)
        next
      end
      if question.question_type == "header"
        next
      end
      total_questions += 1
      if question.option_configs.length > 0
        @question_to_option_hash[question.id] = question.option_configs
      end
    end

    set_response_info(response_hash, ordered_subjects, all_responses, subject_date_hash, use_codes, empty_code, blocked_code)

    if form.is_many_to_one
      grid_header.push({
        value: form.secondary_id,
        type: "text"
      })
    end
    i = 0
    form.form_questions.sort do |a,b|
      a.sequence_number.to_i<=>b.sequence_number.to_i
    end.each do |question|
      if question.personally_identifiable and (!can_phi or !use_phi)
        next
      end
      if question.question_type == "header"
        next
      end
      checkbox_answer_choices = []
      if @export_checkbox_horizontal and question.question_type == "checkbox"
        checkbox_answer_choices = CheckboxExporter.add_question_to_header(grid_header, question, question.variable_name, use_codes)
      else
        grid_header.push({
          value: question.variable_name,
          type: question.question_type
        })
      end

      other_columns = OtherQuestionTypeGridHandler.get_and_push_other_questions(question, grid_header, )
      grid_index = 0
      ordered_subjects.each_with_index do |subject_id|
        response_hash[subject_id].each do | instance_number, instance|
        #instance = response_hash[subject_id][instance_index.to_s]
          if i == 0
            if include_percent
              #percent = response_hash[subject_id][:num_answers] / total_questions
              formatted_percent = "0"#sprintf("%0.02f", percent.round(4) * 100).to_s
              grid_data.push([{:value => subject_id, :exception => false},
                              {:value => formatted_percent, :exception => false}
                             ])
            else
              grid_data.push([{:value => subject_id, :exception => false}])
            end
            if form.is_many_to_one
              grid_data[grid_index].push({:value => instance["secondary id"], :exception => false})
            end
          end
          if instance[question.id]
            temp_answer = instance[question.id][:value].to_s
            no_other_answer = ""
            if temp_answer != nil and (temp_answer.include?("\u200C") or temp_answer.include?("\u200A"))
              temp_answer.split("\u200C").each_with_index do |answer_part, part_index|
                if part_index != 0
                  no_other_answer += "|"
                end
                no_other_answer += (answer_part.try(:split, "\u200A") || []).first || ""
              end
              #temp_answer = temp_answer.split("\u200C").join("|")
            else
              no_other_answer = temp_answer
            end
            answer_val = AnswerStringFormatter.format(no_other_answer, question.question_type, empty_code, blocked_code)
            if @export_checkbox_horizontal and question.question_type == "checkbox"
              CheckboxExporter.add_answer_to_grid(grid_data, grid_index, checkbox_answer_choices, temp_answer, empty_code, use_codes)
            else
              grid_data[grid_index].push({value: answer_val, exception: false})
            end

            OtherQuestionTypeGridHandler.push_other_question_answers(other_columns, temp_answer, grid_index, grid_data, empty_code, blocked_code, use_codes)
          else
            if @export_checkbox_horizontal and question.question_type == "checkbox"
              CheckboxExporter.add_answer_to_grid(grid_data, grid_index, checkbox_answer_choices, nil, empty_code, use_codes)
            else
              grid_data[grid_index].push({value: "", exception: false})
            end
            other_columns.each do |col|
              grid_data[grid_index].push({value: "", exception: false})
            end
          end
          grid_index += 1
        end
      end
      i += 1
    end
    grid = grid_data.map do |row|
      row.map do |entry|
        entry[:value]
      end
    end
    return {
      grid: grid,
      gridHeader: grid_header,
      subjectDates: subject_date_hash
    }
    all_responses = nil
    response_hash = nil
    GC.start
  end

  def get_team_member_rs(proj_id, user_id)
    rs = TeamMember.where("project_id=? and user_id=?", proj_id, user_id).first
    if rs == nil
      raise PayloadException.access_denied "user is not a valid team member"
    end
    rs
  end

  def get_form_responses_rs(form)
    #return FormResponse.includes(:form_answers).
    #  includes(:form_questions).where("form_structure_id=?", form.id).
    #  order(:created_at, :instance_number)
    sql = <<-SQL
        SELECT r.id AS response_id, a.answer AS answer, r.subject_id AS subject_id,
          r.instance_number AS instance_number, r.secondary_id as secondary_id,
          r.created_at AS response_created_at, r.updated_at AS response_updated_at,
          a.form_question_id AS question_id, a.regular_exception AS regular_exception,
          a.year_exception AS year_exception, a.month_exception AS month_exception,
          a.day_exception AS day_exception
        FROM form_answers a, form_responses r
        WHERE (
          a.form_response_id=r.id AND
          r.form_structure_id='#{form.id}' AND
          a.deleted_at IS NULL AND
          r.deleted_at IS NULL
        )
        ORDER BY r.subject_id, r.instance_number, r.id
      SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def set_response_info(response_hash, ordered_subjects, all_responses, subject_date_hash, use_code=false, empty_code="", blocked_code="\u200D")
    cur_response_id = nil
    new_response = false
    all_responses.each do |record|

      if cur_response_id != record["response_id"]
        new_response = true
        cur_response_id = record["response_id"]
      else
        new_response = false
      end

      if new_response
        unless response_hash.has_key?(record["subject_id"])
          init_response_structures(response_hash, ordered_subjects, record, subject_date_hash)
        end
        update_subject_date_hash(record, subject_date_hash)
      end
      answer_str = record["answer"]
      if use_code and @question_to_option_hash.has_key?(record["question_id"])
        answer_parts = answer_str.try(:split, "\u200c") || []
        converted_answer_parts = answer_parts.map do |part_str|
          no_other_part = (part_str.try(:split, "\u200A") || []).first || ""
          @question_to_option_hash[record["question_id"]].each do |option|
            if no_other_part != nil and option.value != nil and no_other_part.upcase == option.value.upcase
              no_other_part = option.code
              break
            end
          end
          if part_str.include?("\u200A")
            second_part = part_str.split("\u200A").second
            "#{no_other_part}\u200A#{second_part}"
          else
            no_other_part
          end
        end
        answer_str = converted_answer_parts.join("\u200c")
      end
      instance_number = record["instance_number"]
      unless response_hash[record["subject_id"]].include?(instance_number)
        response_hash[record["subject_id"]][instance_number] = {"secondary id" => record["secondary_id"]}
      end
      #if answer.answer != ""
      #  response_hash[record["subject_id"][:num_answers] += 1
      #end
      response_hash[record["subject_id"]][instance_number][record["question_id"]] = {value: answer_str, exception: false}
      #end
    end
  end

  def init_response_structures(response_hash, ordered_subjects, record, subject_date_hash)
    response_hash[record["subject_id"]] = {}#{:num_answers => 0}
    ordered_subjects.push(record["subject_id"])
    subject_date_hash[record["subject_id"]] = {
        :created => record["created_at"].to_i,
        :modified => record["updated_at"].to_i
      }
  end

  def update_subject_date_hash(record, subject_date_hash)
    if record["created_at"].to_i < subject_date_hash[record["subject_id"]][:created]
      subject_date_hash[record["subject_id"]][:created] =  record["created_at"].to_i
    end
    if record["updated_at"].to_i > subject_date_hash[record["subject_id"]][:modified]
      subject_date_hash[record["subject_id"]][:modified] = record["updated_at"].to_i
    end
  end

end
