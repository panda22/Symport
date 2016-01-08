class QueryValidator
	class << self
		def get_errors(query)
			is_error = false
			errors = []
			query.query_params.each do |param|
				error = validate_param(param)
				errors.push(error)
				unless error.empty?
					is_error = true
				end
			end
			errors
		end

		def validate(query_info, project_id, user)
			is_error = false
			errors = []
			project = Project.find(project_id)
			temp_query = QueryUpdater.create(query_info, project, user)
			unless query_info[:queryParams].nil?
				for param in query_info[:queryParams]
					temp_query.query_params << QueryUpdater.create_param(param, project_id)
				end
			end
			temp_query.query_params.each do |param|
				error = validate_param(param)
				errors.push(error)
				unless error.empty?
					is_error = true
				end
			end
			if is_error
				raise PayloadException.new(422, errors)
			end
		end

		# returns error string or nil if no error
		def validate_param(param)
			error = {}
			if param.form_structure_id == nil
				error[:formName] = "Please specify"
				return error
			end
			form = FormStructure.find(param.form_structure_id)
			if form.nil?
				error[:formName] = "Please specify"
				return error
			end
			if param.is_many_to_one_count
				validate_many_to_one_count(form, error, param)
			elsif param.is_many_to_one_instance
				validate_many_to_one_instance(form, error, param)
			else
				validate_normal_question(error, param)
			end

		end

		private
		def validate_normal_question(error, param)
			operator = param.operator
			value = param.value
			question = param.form_question
			if question.nil?
				error[:questionName] = "Please specify"
				return error
			end
			if operator.nil? or operator == ""
				error[:operator] = "Please specify"
			end
			if param.is_many_to_one_instance or param.is_many_to_one_count
				return error
			end
			equal_not_equal = operator == "≠" || operator == "="
			fake_answer = FormAnswer.new({form_question_id: question.id})
			exception = equal_not_equal && FormAnswerExceptor.check_exceptions(question, fake_answer, value, true)
			unless exception
				temp_error = FormAnswerValidator.validate(question, value)
				if temp_error
					error[:value] = temp_error
				elsif value == nil
					error[:value] = "Please specify"
				end
			end
			return error
		end

		def validate_many_to_one_instance(form, error, param)
			operator = param.operator
			unless form.is_many_to_one
				error[:questionName] = "invalid many to one instance request"
			end
			unless operator == "=" or operator == "≠"
				error[:operator] = "must be = or ≠"
			end
			return error
		end

		def validate_many_to_one_count(form, error, param)
			operator = param.operator
			value = param.value
			if form.is_many_to_one == false
				error[:questionName] = "invalid many to one instance request"
			end
			if operator.nil? or operator == ""
				error[:operator] = "Please specify"
			end
			if value.to_i.to_s != value or value.to_i < 0 #check for integer
				error[:value] = "must be an integer greater than or equal to 0"
			end
			return error
		end
	end
end