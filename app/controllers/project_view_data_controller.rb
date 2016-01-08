class ProjectViewDataController < ApplicationController
	skip_before_filter :header_authenticate!, only: :download_results
	before_filter :form_authenticate!, only: :download_results

	def get_view_data
		GC.start

		@proj_id = params[:id]
		@no_data_error = nil
		project, @no_data_error = ProjectGridLookup.get_project_rs(@proj_id)
		team_member_rs = ProjectGridLookup.get_team_member_rs(@proj_id, current_user)
		form_permission_rs = ProjectGridLookup.get_form_permission_rs(@proj_id, current_user)
		response_rs = ProjectGridLookup.get_form_responses_rs(@proj_id)
		if response_rs.count == 0 and @no_data_error == nil
			@no_data_error = "response"
		end
		@can_view_identifiable = team_member_rs.view_personally_identifiable_answers
		@is_admin = team_member_rs.administrator

		@question_to_form_hash = {}
		@form_permission_hash = {}
		@form_blocked = false
		@total_questions = 0
		form_permission_rs.each do |permission|
			@form_permission_hash[permission.form_structure_id] = permission
		end
		forms = []
		@form_indexes = {}
		@form_hash = {}
		set_forms(forms, project, false)
		if @total_questions == 0 and @no_data_error == nil
			@no_data_error = "formPermission"
		end
		@response_hash = {}
		@num_subjects = 0
		@ordered_subjects = []
		@subject_date_hash = {}
		set_responses(response_rs)

		@export_checkbox_horizontal = false
 		
 		@grid = []
 		@ordered_questions = []
 		set_grid(false, forms)
 		if @grid.length == 0 and @no_data_error == nil
 			@no_data_error = "questionPermission"
		end
 		return_json = get_return_obj(team_member_rs[:export])
 		AuditLogger.view(current_user, Project.find(@proj_id))
		response_rs = nil
		@response_hash = nil
		GC.start
 		render json: MultiJson.dump(return_json)
	end

	def get_forms_and_questions
		@proj_id = params[:id]
 		project, @no_data_error = ProjectGridLookup.get_project_rs(@proj_id)
 		team_member_rs = ProjectGridLookup.get_team_member_rs(@proj_id, current_user)
 		
 		form_permission_rs = ProjectGridLookup.get_form_permission_rs(@proj_id, current_user)
 		
 		@can_view_identifiable = team_member_rs.view_personally_identifiable_answers
 		@is_admin = team_member_rs.administrator
 		#form_instance_hash = ProjectGridLookup::get_max_instances_by_form(@proj_id)
 		@form_permission_hash = {}
 		@form_blocked = false
 		@total_questions = 0
 		secondary_id_hash = ProjectGridLookup::get_secondary_id_names_by_form(@proj_id)
 		form_permission_rs.each do |permission|
 			@form_permission_hash[permission.form_structure_id] = permission
 		end
 		forms = []
		@is_phi_block = false
 		project.form_structures.sort do |a,b|
			a.created_at.to_date <=> b.created_at.to_date
		end.each do |form|
 			is_displayed = (form.form_questions.length == 0) ? false : true
 			if is_allowed_form?(form, @can_view_identifiable)
 				all_phi_blocked = nil
 				new_form = {
	 				:id => form.id,
	 				:name => form.name,
	 				:questions => [],
	 				:isDisplayed => is_displayed,
	 				:isChecked => is_displayed,
	 				:isManyToOne => form.is_many_to_one
	 			}
				if form.is_many_to_one
					new_form[:questions].push({
						:id => "",
						:isPhi => false,
						:prompt => "",
						:variableName => "number of #{form.secondary_id}",
						:type => "numericalrange"
					},
					{
						:id => "",
						:isPhi => false,
						:prompt => "",
						:variableName => form.secondary_id,
						:type => "dropdown"
					})
				end
				form.form_questions.sort do |a,b|
					a.sequence_number.to_i<=>b.sequence_number.to_i
				end.each do |question|
	 				if question.question_type == "header"
	 					next
	 				end
	 				if question.personally_identifiable == true and @can_view_identifiable == false
						@is_phi_block = true
	 					if all_phi_blocked == nil
	 						all_phi_blocked = true
	 					end
	 					next
	 				end
	 				all_phi_blocked = false
	 				new_form[:questions].push({
	 						:id => question.id,
	 						:isPhi => question.personally_identifiable,
	 						:prompt => question.prompt,
	 						:variableName => question.variable_name,
	 						:type => question.question_type
	 					})
	 			end
 				unless all_phi_blocked
 					forms.push(new_form)
 				end
 			end
 		end

 		render json: MultiJson.dump({
 			forms: forms,
 			secondaryIds: secondary_id_hash,
			formBlocked: @form_blocked,
			phiBlocked: @is_phi_block
 		})
	end

	def get_query_data
		@proj_id = params[:query][:projectID]
		@query_params = params[:query][:queryParams] || []
		@query_params.each do |param|
			set_query_param_exception_flag(param)
		end
		@num_exception_removed = 0
		@queried_form_hash = get_query_form_hash(params[:query][:queriedForms])
		@conjunction = params[:query][:conjunction] || "and"
		#@queried_form_hash = params[:form_hash] || []
		#@conjunction = params[:query][:conjunction] || "and"
 		project, @no_data_error = ProjectGridLookup.get_project_rs(@proj_id)
 		team_member_rs = ProjectGridLookup.get_team_member_rs(@proj_id, current_user)
 		
 		form_permission_rs = ProjectGridLookup.get_form_permission_rs(@proj_id, current_user)
 		response_rs = ProjectGridLookup.get_form_responses_rs(@proj_id)
 		
 		@can_view_identifiable = team_member_rs.view_personally_identifiable_answers
 		@is_admin = team_member_rs.administrator
 		
 		@question_to_form_hash = {}
 		@form_permission_hash = {}
 		@form_blocked = false
 		@total_questions = 0
 		form_permission_rs.each do |permission|
 			@form_permission_hash[permission.form_structure_id] = permission
 		end
 		forms = []
 		queried_forms = []
 		@form_indexes = {}
 		@form_hash = {}
 		set_forms(forms, project, true, queried_forms)
 		

 		@response_hash = {}
 		@num_subjects = 0
 		@ordered_subjects = []
 		@subject_date_hash = {}
 		set_responses(response_rs)

		@export_checkbox_horizontal = false


 		
 		@grid = []
 		@ordered_questions = []
 		instance_info = []
 		set_grid(true, forms, instance_info)
 		return_json = get_return_query_obj(queried_forms, team_member_rs[:export], instance_info)
		AuditLogger.view current_user, project
 		render json: MultiJson.dump(return_json)
	end

	def download_results
		query = JSON.parse(params[:query])
		download_options = JSON.parse(params[:downloadOptions])
		@proj_id = query["projectID"]
		@query_params = []
		unless query["queryParams"] == nil or query["queryParams"] == ""
			@query_params = query["queryParams"]
		end
		@query_params.each do |param|
			set_query_param_exception_flag(param)
		end
		if query["queriedForms"] == nil or query["queriedForms"] == ""
			@queried_form_hash = {}
		else
			@queried_form_hash = get_query_form_hash(query["queriedForms"])
		end
		@num_exception_removed = 0
		@conjunction = query["conjunction"] || "and"
		@question_to_form_hash = {}
		@include_phi = download_options["includePhi"]
		use_variable_codes = download_options["useCodes"]
		empty_answer_code = download_options["emptyCode"]
		conditionally_blocked_code = download_options["blockedCode"]
 		project, @no_data_error = ProjectGridLookup.get_project_rs(@proj_id)
 		team_member_rs = ProjectGridLookup.get_team_member_rs(@proj_id, current_user)
 		
 		form_permission_rs = ProjectGridLookup.get_form_permission_rs(@proj_id, current_user)
 		response_rs = ProjectGridLookup.get_form_responses_rs(@proj_id)

 		unless team_member_rs[:export]
			raise PayloadException.access_denied "user does not have download permissions"
		end
 		
 		@can_view_identifiable = (@include_phi and team_member_rs.view_personally_identifiable_answers)
 		@is_admin = team_member_rs.administrator
 		
 		@form_permission_hash = {}
 		@form_blocked = false
 		@total_questions = 0
 		form_permission_rs.each do |permission|
 			@form_permission_hash[permission.form_structure_id] = permission
 		end
 		forms = []
 		queried_forms = []
 		@form_indexes = {}
 		@form_hash = {}
 		set_forms(forms, project, true, queried_forms)

		@export_checkbox_horizontal = false
		unless download_options["checkboxHorizontal"].nil?
			@export_checkbox_horizontal = download_options["checkboxHorizontal"]
		end
 		
 		@response_hash = {}
 		@num_subjects = 0
 		@ordered_subjects = []
 		@subject_date_hash = {}
 		set_responses(response_rs, use_variable_codes, empty_answer_code, conditionally_blocked_code)
 		@grid = []
 		@ordered_questions = []
 		instance_info = []
 		set_grid(true, forms, instance_info, false, empty_answer_code, conditionally_blocked_code, use_variable_codes)
		export_headers = []
 		@ordered_questions.each do |ques|
 			export_headers.push(ques[:value])
 		end

 		phi_file_string = (@include_phi) ? "-includes-identifying-information" : ""
 		time = Time.now.strftime("%m/%d/%yT%I:%M:%S")
 		grid = @grid.map do |row|
 			row.map do |entry|
 				entry[:value]
 			end
 		end
 		csv_str = CsvTableConverter.convert(grid, export_headers)
 		file_name = "#{project.name}#{phi_file_string}#{time}.csv"

    	AuditLogger.export(current_user, project, file_name, export_headers)
    	cookies[:labcompass_download_file] = "success"

 		send_data csv_str, type: "text/csv", filename: file_name
	end

	#######################################################################################################
	#
	# private functions
	#
	#######################################################################################################
	def validate_query_params
		QueryParamValidator.validate_value(params[:project_id], params[:query_params])
		render json: {result: "success"}
	end

	private

	def get_query_form_hash(query_forms)
		if query_forms == nil
			return {}
		end
		obj = {}
    query_forms.each do |form|
			obj[form["formID"]] = form["included"]
		end
		obj
	end

	def set_forms (forms, project, has_query_params, queried_forms=[])
		@all_instance_counts = {}
		@question_to_options_hash = {}
		project.form_structures.sort do |a,b|
			a.created_at.to_date <=> b.created_at.to_date
		end.each_with_index do |form, i|
			if is_allowed_form?(form, @can_view_identifiable)
				if form.is_many_to_one
					@all_instance_counts[form.secondary_id] = form.form_responses.count
				end
				if has_query_params == false or  (@queried_form_hash.has_key?(form.id) and @queried_form_hash[form.id] == true)
					@form_hash[form.id] = true
					@total_questions += form.form_questions.length
					if has_query_params
						queried_forms.push(form.name)
					end
				end
				forms.push(form)
				@form_indexes[form.name] = {:id => form.id, :column_indexes => []}
				if form.is_many_to_one
					@question_to_form_hash[form.secondary_id] = {
							name: form.name,
							index: i
					}
				end
				form.form_questions.each do |question|
					OtherQuestionTypeGridHandler.add_other_question_to_form_hash(question, @question_to_form_hash, i)
					@question_to_form_hash[question.variable_name] = {
						name: form.name,
						index: i
					}
					if question.option_configs.length > 0
						@question_to_options_hash[question.id] = question.option_configs
					end
				end
			end
		end
		queried_forms.each_with_index do |formName, i|
			unless i == 0
				queried_forms[i] = ", #{formName}"
			end
		end
	end

	def set_query_param_exception_flag(param)
		exception = false
		if param["isManyToOneInstance"] == false and param["isManyToOneCount"] == false
			form = FormStructure.find_by(:project_id => @proj_id, :name => param["formName"])
			question = FormQuestion.find_by(:form_structure_id => form.id, :variable_name => param["questionName"])
			operator = param["operator"]
			equal_not_equal = operator == "≠" || operator == "="
			fake_answer = FormAnswer.new({form_question_id: question.id})
			value = param["value"]
			exception = equal_not_equal && FormAnswerExceptor.check_exceptions(question, fake_answer, value, false)
		end
		param["isException"] = exception
		param["removed_exception_rows"] = []
	end
	

	def set_responses (response_rs, show_variable_codes=false, empty_code="", blocked_code="\u200D")
		cur_response_id = nil
		new_response = false
		response_rs.each do |record|
			# handle created at and modified at
			# these are used as sorting methods on the front end (Subject First Created On Top, etc..)

			if cur_response_id != record["response_id"]
				new_response = true
				cur_response_id = record["response_id"]
			else
				new_response = false
			end

			##
			#
			# handle response
			#
			##
			if new_response
				if !@subject_date_hash.has_key?(record["subject_id"])
					@subject_date_hash[record["subject_id"]] = {
						:created => DateTime.parse(record["response_created_at"]).to_i,
						:modified => DateTime.parse(record["response_created_at"]).to_i
					}
				else
					if DateTime.parse(record["response_created_at"]).to_i < @subject_date_hash[record["subject_id"]][:created]
						@subject_date_hash[record["subject_id"]][:created] = DateTime.parse(record["response_created_at"]).to_i
					end
					if DateTime.parse(record["response_created_at"]).to_i > @subject_date_hash[record["subject_id"]][:modified]
						@subject_date_hash[record["subject_id"]][:modified] = DateTime.parse(record["response_created_at"]).to_i
					end
				end
				# create entry in response_hash and push subject_id in to ordered subject array
				unless @response_hash.has_key?(record["subject_id"])
					@response_hash[record["subject_id"]] = {
						:subj_position => @num_subjects,
						:responses => {},
						:secondary_ids => {}
					}

					@num_subjects += 1
					@ordered_subjects.push(record["subject_id"])
				end
				unless @response_hash[record["subject_id"]][:secondary_ids].has_key?(record["form_id"])
					@response_hash[record["subject_id"]][:secondary_ids][record["form_id"]] = []
				end
				#append answers to response_hash[subject_id][:responses][variable_name][instance_number]
				cur_secondary_ids = @response_hash[record["subject_id"]][:secondary_ids][record["form_id"]]
				cur_secondary_ids.push(record["secondary_id"])
			end
			cur_responses = @response_hash[record["subject_id"]][:responses]


			##
			#
			# handle answer
			#
			##
			answer_str = record["answer"]
			if show_variable_codes and @question_to_options_hash[record["question_id"]] != nil
				answer_parts = answer_str.try(:split, ("\u200c")) || []
				converted_answer_parts = answer_parts.map do |part_str|
					no_other_part = (part_str.try(:split, ("\u200A")) || []).first || ""
					@question_to_options_hash[record["question_id"]].each do |option|
						if no_other_part != nil and option.value != nil and no_other_part.upcase == option.value.upcase
							no_other_part = option.code
							break
						end
					end
					if part_str.include?("\u200A")
						second_part = (part_str.try(:split, ("\u200A")) || []).second || ""
						"#{no_other_part}\u200A#{second_part}"
					else
						no_other_part
					end
				end
				answer_str = converted_answer_parts.join("\u200c")
			end
			is_exception = !(record["regular_exception"].nil? and record["year_exception"].nil? and record["month_exception"].nil? and record["day_exception"].nil? and record["error_message"] == "")
			# TODO: add is_error to exception_obj
			# TODO: convert empty string to null in object
			exception_obj = {
					:regular => record["regular_exception"],
					:day => record["day_exception"],
					:month => record["month_exception"],
					:year => record["year_exception"],
					:is_error => (record["error_message"] == "") ? nil : record["error_message"]
			}
			unless cur_responses.has_key?(record["question_id"])
				cur_responses[record["question_id"]] = []
			end
			cur_responses[record["question_id"]][record["instance_number"].to_i] = {value: answer_str, exception: is_exception, exception_obj: exception_obj}
		end
	end
	
	def set_grid(has_query_params, forms, instance_info=[], has_percent_filled=true, empty_code="", blocked_code="\u200D", use_codes=false)
		all_removed_subjects = []
		if has_query_params
			@query_params.each do |param|
				param[:is_many_to_one] = false
				param[:allowed_subjects] = []
				param[:removed_subjects] = []
				param[:allowed_secondary_ids] = {}
				param[:removed_secondary_ids] = {}
				param[:instance_count] = 0
				param[:total_subjects] = @ordered_subjects.length
				param[:form_secondary_id] = nil
			end
		end
		# TODO: delete this line to bring back filled percent column
		has_percent_filled = false
		if has_percent_filled
			@ordered_questions = [
					{value: "Subject ID" ,type: "text"},
	 				{value: "Total Filled %", type: "numericalrange"}
			]
	 	else
	 		@ordered_questions = [{value: "Subject ID" ,type: "text"}]
	 	end
 		cur_column = 0
		extra_many_to_one_columns = 0
 		first_column_set = false
		form_instance_hash = ProjectGridLookup::get_max_instances_by_form(@proj_id)
 		forms.sort do |a,b|
			b.updated_at.to_i <=> a.updated_at.to_i
		end.each do |form|
			#@log.puts("\t#{Time.now.strftime("%I:%M:%S")}inside form loop for set_grid")
 			all_phi_blocked = nil
 			unless is_allowed_form?(form, @can_view_identifiable)
 				#add from permission block
 				next
 			end
 			is_displayed_form = (has_query_params) ? @queried_form_hash[form.id] : true
			num_instances = (form_instance_hash.has_key?(form.id)) ? form_instance_hash[form.id] : 1
			(0...num_instances).each do |instance_number|
				if form.is_many_to_one and form.form_questions.length > 0 and is_displayed_form
					if instance_number == 0
						@form_indexes[form.name][:column_indexes].push(cur_column + 1 + extra_many_to_one_columns)
						extra_many_to_one_columns += 1
						@ordered_questions.push({
							value: "number of #{form.secondary_id}",
							type: "numericalrange"
						})
					end
					@form_indexes[form.name][:column_indexes].push(cur_column + 1 + extra_many_to_one_columns)
					extra_many_to_one_columns += 1
					@ordered_questions.push({
						value: "#{form.secondary_id}_#{instance_number + 1}",
						type: "text"
					})
				end
				skipped_questions = 0
				form.form_questions.sort do |a,b|
					a.sequence_number.to_i<=>b.sequence_number.to_i
				end.each_with_index do |question, question_num|
					if question.question_type == "header"
						skipped_questions += 1
						next
					end
					if question.personally_identifiable == true and @can_view_identifiable == false
						if all_phi_blocked == nil
							all_phi_blocked = true
						end
						skipped_questions += 1
						next
					end

					all_phi_blocked = false
					# used for export checkbox horizontally
					question_checkbox_names = []
					if is_displayed_form
						@form_indexes[form.name][:column_indexes].push(cur_column + 1 + extra_many_to_one_columns)
						var_name = (num_instances > 1) ? "#{question.variable_name}_#{instance_number + 1}" : question.variable_name
						if @export_checkbox_horizontal and question.question_type == "checkbox"
							question_checkbox_names = CheckboxExporter.add_question_to_header(@ordered_questions, question, var_name, use_codes)
						else
							@ordered_questions.push({
								value: var_name,
								type: question.question_type
							})
						end
						other_columns = OtherQuestionTypeGridHandler.get_and_push_other_questions(question, @ordered_questions, num_instances, instance_number)
						other_columns.each_with_index do |config, k|
							@form_indexes[form.name][:column_indexes].push(cur_column + 2 + k + extra_many_to_one_columns)
						end
					end
					var_name = question.variable_name
					ques_id = question.id
					@ordered_subjects.each_with_index do |subject_id, i|
						if cur_column == 0 and first_column_set == false and instance_number == 0
							if has_percent_filled
								percent = 0 #(@total_questions == 0) ? 0 : (@response_hash[subject_id][:num_answers] / @total_questions.to_f)
								percent_string = sprintf("%0.02f", percent.round(4) * 100).to_s
								@grid.push([
		 							{value: subject_id, exception: false},
		 							{value: percent_string, exception: false}
	 							])
							else
								@grid.push([{value: subject_id, exception: false}])
							end
						end
						#insert many to one answers for count and instance_number
						#count is inserted at beginning of form and instance number at beginning of each instance
						if form.is_many_to_one and question_num - skipped_questions == 0
							cur_secondary_id = @response_hash[subject_id][:secondary_ids][form.id][instance_number] rescue nil
							if instance_number == 0
								num_response_instances = "0"
								if @response_hash[subject_id][:responses][ques_id]
									num_response_instances = @response_hash[subject_id][:responses][ques_id].length.to_s
								end
								if has_query_params
									is_allowed_by_query?("number of #{form.secondary_id}", num_response_instances, i, nil, instance_number, form.is_many_to_one, form.secondary_id, is_displayed_form)
									#filter_by_query("number of #{form.secondary_id}", num_response_instances, i, cur_secondary_id)
								end
								if is_displayed_form
									@grid[i].push({value: num_response_instances, is_exception: false})
								end
							end

							if has_query_params
								#filter_by_query(form.secondary_id, cur_secondary_id, i, cur_secondary_id)
								is_allowed_by_query?(form.secondary_id, cur_secondary_id, i, nil, instance_number, form.is_many_to_one, form.secondary_id, is_displayed_form)
							end
							if is_displayed_form
								@grid[i].push({value: cur_secondary_id, isException: false})
							end
						end
						cur_secondary_id = nil
						if form.is_many_to_one
							cur_secondary_id = @response_hash[subject_id][:secondary_ids][form.id][instance_number] rescue nil
						end
						if @response_hash[subject_id][:responses][ques_id] and @response_hash[subject_id][:responses][ques_id][instance_number] and instance_number < @response_hash[subject_id][:responses][ques_id].length
							temp_answer = @response_hash[subject_id][:responses][ques_id][instance_number][:value].to_s
							no_other_answer = ""
							if temp_answer != nil and (temp_answer.include?("\u200C") or temp_answer.include?("\u200A"))
								(temp_answer.try(:split, ("\u200C")) || []).each_with_index do |answer_part, part_index|
									if part_index != 0
										no_other_answer += "|"
									end
									no_other_answer += (answer_part.try(:split, ("\u200A")) || []).first || ""
								end
							else
								no_other_answer = temp_answer
							end
							exception_obj = @response_hash[subject_id][:responses][ques_id][instance_number][:exception_obj] || nil
							query_answer = no_other_answer
							if use_codes
								query_answer = convert_query_answer_from_code(question, query_answer)
							end
							is_allowed = (has_query_params == false or is_allowed_by_query?(var_name, query_answer, i, exception_obj, instance_number, form.is_many_to_one, form.secondary_id, is_displayed_form))
							if is_displayed_form
								is_exception = @response_hash[subject_id][:responses][ques_id][instance_number][:exception]
								if is_allowed
									answer_str = AnswerStringFormatter.format(no_other_answer, question[:question_type], empty_code, blocked_code)
									if @export_checkbox_horizontal and question.question_type == "checkbox"
										CheckboxExporter.add_answer_to_grid(@grid, i, question_checkbox_names, temp_answer, empty_code, use_codes)
									else
										@grid[i].push({:value => answer_str, :is_exception => is_exception})
									end
									OtherQuestionTypeGridHandler.push_other_question_answers(other_columns, temp_answer, i, @grid, empty_code, blocked_code, use_codes)
								end
							end
						else
							blank_val = empty_code
							if form.is_many_to_one and instance_number > 0
								blank_val = "\u200b"
							end
							if has_query_params
								is_allowed_by_query?(var_name, blank_val, i, exception_obj, instance_number, form.is_many_to_one, form.secondary_id, is_displayed_form)
							end
							if is_displayed_form
								is_exception = false
								if form.is_many_to_one and instance_number > 0
									if has_percent_filled
										@grid[i].push({:value => blank_val, :is_exception => false})
									else
										if @export_checkbox_horizontal and question.question_type == "checkbox"
											CheckboxExporter.add_answer_to_grid(@grid, i, question_checkbox_names, nil, empty_code, use_codes)
										else
											@grid[i].push({:value => "", :is_exception => false})
										end
									end
								else
									if @export_checkbox_horizontal and question.question_type == "checkbox"
										CheckboxExporter.add_answer_to_grid(@grid, i, question_checkbox_names, nil, empty_code, use_codes)
									else
										@grid[i].push({:value => blank_val, :is_exception => false})
									end
								end
								OtherQuestionTypeGridHandler.push_other_question_answers(other_columns, "", i, @grid, empty_code, blocked_code, use_codes)
							end
						end
					end
					first_column_set = true
					if is_displayed_form
						cur_column = cur_column + 1 + other_columns.length
					end
				end
			end
			if all_phi_blocked
				@form_indexes.delete(form.name)
			end
 		end
 		if has_query_params
	 		all_removed_subjects = get_all_removed_subjects
	 		remove_rows_blocked_by_query(all_removed_subjects)
			set_instance_info()
	 	end
	end

	def convert_query_answer_from_code(question, val)
		case question.question_type
			when "yesno", "checkbox", "radio", "dropdown"
				question.option_configs.each do |option|
					if option.code == val
						return option.value
					end
				end
				return val
			else
				return val
		end
	end

	def set_instance_info()
		@all_allowed_instances = {}
		@query_params.each_with_index do |param, index|
			if param[:allowed_secondary_ids].empty?
				next
			end
			unless @all_allowed_instances.has_key?(param[:form_secondary_id])
				@all_allowed_instances[param[:form_secondary_id]] = {}
			end
			param[:allowed_secondary_ids].each do |row_num, instances|
				param[:instance_count] += instances.count
				if @all_allowed_instances[param[:form_secondary_id]].has_key?(row_num) == false
					@all_allowed_instances[param[:form_secondary_id]][row_num] = instances
				else
					if @conjunction == "and"
						@all_allowed_instances[param[:form_secondary_id]][row_num] &= instances
					else
						@all_allowed_instances[param[:form_secondary_id]][row_num] |= instances
					end
				end
			end
		end
		@allowed_instance_counts = {}
		@all_allowed_instances.each do |form_secondary_id, form_instances|
			@allowed_instance_counts[form_secondary_id] = 0
			form_instances.each do |row_num, instances|
				@allowed_instance_counts[form_secondary_id] += instances.count
			end
		end
	end

	def is_allowed_by_query?(var_name, answer, row_num, exception_obj, instance_number, is_many_to_one, form_secondary_id, is_displayed_form)
		@query_params.each do |param|
			unless var_name == param["questionName"]
				next
			end
			if is_many_to_one and is_displayed_form
				param[:form_secondary_id] = form_secondary_id
				param[:is_many_to_one] = true
				unless param[:allowed_secondary_ids].has_key?(row_num)
					param[:allowed_secondary_ids][row_num] = []
				end
				unless param[:removed_secondary_ids].has_key?(row_num)
					param[:removed_secondary_ids][row_num] = []
				end
			end
			if is_allowed_by_param?(answer, param, exception_obj)
				param[:allowed_subjects].push(row_num)
				if is_many_to_one and is_displayed_form
					param[:allowed_secondary_ids][row_num].push(instance_number)
				end
			else
				param[:removed_subjects].push(row_num)
				if is_many_to_one and is_displayed_form
					param[:removed_secondary_ids][row_num].push(instance_number)
				end
				obj = exception_obj
				unless obj.nil?
					# TODO: include is_error to error arrays
					is_exception = (obj[:regular] or obj[:year] or obj[:month] or obj[:day])
					if (param["isException"] == false and is_exception) or obj[:is_error]
						unless param.has_key?("removed_exception_rows")
							param["removed_exception_rows"] = []
						end
						param["removed_exception_rows"].push(row_num)
					else
						unless param.has_key?("allowed_exception_rows")
							param["allowed_exception_rows"] = []
						end
						param["allowed_exception_rows"].push(row_num)
					end
				end
			end
		end
	end

	def is_allowed_by_param?(answer, param, exception_obj)
		if answer == nil
			return false
		end
		if answer == "\u200b" # many to one instance > 0 not filled
			return false
		end
		operator = param["operator"]
		type = param["questionType"]
		up_val = (param["value"] == nil) ? nil : param["value"].upcase
		up_answer = (answer == nil) ? nil : answer.upcase

		if type == "date" and param["value"].include?("#")
			return QueryComparator.compare_wildcard(operator, up_val, up_answer)
		end

		obj = exception_obj
		# TODO: exclude is_error from this check
		is_exception = false
		unless obj.nil?
			is_exception = (obj[:regular] or obj[:year] or obj[:month] or obj[:day])
		end
		if type == "date" and is_exception and operator != "=" and operator != "≠"
			return QueryComparator.compare_date_exception(operator, up_answer, up_val, exception_obj)
		end


		# TODO include is_error in this check
		if obj.nil? == false and obj[:is_error]
			return false
		elsif !param["isException"] and  is_exception
			return false
		elsif param["isException"] and !is_exception and param["operator"] == "="
			return false
		elsif param["isException"] and param["questionType"] == "timeofday"
			answer = answer.gsub(/ PM| pm| AM| am/, "")
			param["value"] = param["value"].gsub(/ PM| pm| AM| am/, "")
		end


		converted_val = AnswerTypeConverter.convert(up_val, param["questionType"])
		converted_answer = AnswerTypeConverter.convert(up_answer, param["questionType"])
		QueryComparator.compare(param["operator"], converted_answer, converted_val)
	end

	def get_all_removed_subjects
		ret_arr = []
		secondary_id_result = {}
		if @conjunction == "and"
			@query_params.each do |param|
				unless secondary_id_result.has_key?(param["formName"])
					secondary_id_result[param["formName"]] = []
				end
				param[:removed_subjects] -= param[:allowed_subjects]
				# ret_arr is unique values sorted from largest to smallest
				param[:removed_subjects].each do |subject_index|
					ret_arr.sort! { |a,b| b <=> a } unless (ret_arr << subject_index).uniq!
				end
			end
		elsif @conjunction == "or"
			@query_params.each_with_index do |param, i|
				# ret_arr is all values that are in every query param, same sorting
				if i == 0
					ret_arr = param[:removed_subjects]
					ret_arr.sort!(){ |a,b| b <=> a}.uniq!
				end
				ret_arr -= param[:allowed_subjects]
			end
		end
		remove_instances_from_params(ret_arr)
		ret_arr
	end

	def remove_instances_from_params(removed_subject_rows)
		@query_params.each do |param|
			removed_subject_rows.each do |row_num|
				if param[:allowed_secondary_ids].has_key?(row_num)
					param[:allowed_secondary_ids].delete(row_num)
				end
			end
		end
	end

	def remove_rows_blocked_by_query(subjects)
		removed_exception_rows = get_all_rows_removed_by_exception()
		subjects.each do |index|
			@grid.delete_at(index)
			if removed_exception_rows.include?(index)
				@num_exception_removed += 1
			end
		end
	end

	def get_all_rows_removed_by_exception
		arr = []
		@query_params.each do |param|
			allowed = param["allowed_exception_rows"]
			if  allowed.nil?
				allowed = []
			end
			arr += (param["removed_exception_rows"] - allowed)
		end
		arr.sort!.uniq
	end

	def is_allowed_form?(form, can_view_phi)
		unless Permissions.user_can_view_form_responses_for_form_structure?(current_user, form)
			return false
		end
		unless can_view_phi
			all_blocked = true
			form.form_questions.each do |question|
				unless question.personally_identifiable
					all_blocked = false
				end
			end
			if all_blocked
				@form_blocked = true
				return false
			end
		end
		return true
	end


	def get_return_obj (can_export)
		grid = @grid.map do |row|
			row.map do |entry|
				entry[:value]
			end
		end
		ret_obj = {
			grid: grid,
			gridHeader: @ordered_questions,
			form_indexes: @form_indexes,
			subjectDates: @subject_date_hash,
			noDataError: @no_data_error,
			formBlocked: @form_blocked,
			canExport: can_export,
			questionToForm: @question_to_form_hash
		}
		ret_obj
	end

	def get_return_query_obj (queried_forms, can_export, instance_info)
		total = @ordered_subjects.length - @num_exception_removed
		percent = (total == 0) ? 0 : @grid.length.to_f / total.to_f
		percent_string = sprintf("%0.02f", percent.round(4) * 100).to_s
		grid = @grid.map do |row|
			row.map do |entry|
				entry[:value]
			end
		end
		ret_obj = {
			grid: grid,
			header: @ordered_questions,
			formIndexes: @form_indexes,
			subjectDates: @subject_date_hash,
			formBlocked: @form_blocked,
			questionToForm: @question_to_form_hash,
			canExport: can_export,
			queryInfo: {
				instanceInfo: instance_info,
				params: @query_params,
				total: total,
				removed: (@num_exception_removed > 0) ? @num_exception_removed : nil,
				partial: @grid.length,
				percentage: percent_string,
				queriedForms: queried_forms,
				conjunction: @conjunction,
				canExport: can_export,
				allowedInstanceCounts: @allowed_instance_counts,
				allAllowedInstances: @all_allowed_instances,
				allInstanceCounts: @all_instance_counts
			}
		}
		ret_obj
	end
end
