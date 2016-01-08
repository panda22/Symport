class FormDataController < ApplicationController
  @@initial_response_size = 250

  def get_initial_form_data
   get_form_data(true)
  end

  def get_remaining_form_data
    GC.start()
    get_form_data(false)
    GC.start()
  end

  private
  def get_form_data(is_initial)
    form_id = params[:form_id]
    form = FormStructure.find(form_id)
    can_view = (Permissions.user_can_see_form_structure?(current_user, form) and
      Permissions.user_can_view_form_responses_for_form_structure?(current_user, form))
    if can_view
      can_view_identifiable = Permissions.user_can_view_personally_identifiable_answers_for_project?(current_user, form.project)
      is_completed = ( (is_initial == false) or (form.form_responses.count <= @@initial_response_size) )
      other_questions_rs = FormDataLookup.get_other_questions_rs(form_id)
      other_question_hash = FormDataGridConstructor.construct_other_question_hash(other_questions_rs)
      questions = FormDataLookup.get_form_questions(form_id, can_view_identifiable)
      responses = FormDataLookup.get_responses_rs(form_id, can_view_identifiable, is_initial, @@initial_response_size)
      grid_header = FormDataGridConstructor.construct_header(form, questions, other_question_hash)
      grid_body = FormDataGridConstructor.construct_body(form, responses, other_question_hash)

      errors = {}
      num_errors = 0
      if is_initial
        errors_rs = FormDataLookup.get_answer_error_by_question(form_id, can_view_identifiable)
        errors = FormDataErrorConstructor.construct_from_questions(errors_rs)
        num_errors = errors_rs.count
      end
    else
      grid_header = [[],[]]
      grid_body = []
      is_completed = true
      errors = {}
      num_errors = 0
    end


    # TODO: implement error data structure

    render json: MultiJson.dump({
                                    header: {
                                        left: grid_header[0],
                                        right: grid_header[1]
                                    },
                                    body: grid_body,
                                    initialSize: @@initial_response_size,
                                    isCompleted: is_completed,
                                    formID: form_id,
                                    errors: errors,
                                    numErrors: num_errors,
                                    canView: can_view
                                })
  end


end