class QueryUpdater
	class << self
		def update(query_info, project, user)
			query = nil
			if query_info[:id] == nil or query_info[:id] == ""
				query = QueryUpdater.create(query_info, project, user, true)
			else
				query = Query.find(query_info[:id])
				query.editor = user
			end
			unless Permissions.user_can_update_query?(user, query)
				raise PayloadException.access_denied "you do not have permissions to save this query"
			end
			query.query_params.destroy_all
			unless query_info[:queryParams].nil?
				query_info[:queryParams].each do |param|
					query.query_params << QueryUpdater.create_param(param, project.id, true)
				end
			end
			query.query_form_structures.destroy_all
			unless query_info[:queriedForms].nil?
				query_info[:queriedForms].each do |query_form|
					if query_form[:included]
						query.query_form_structures << QueryFormStructure.create!(:form_structure_id => query_form[:formID])
					end
				end
			end
			query.assign_attributes(
				:editor => user,
				:conjunction => query_info[:conjunction],
				:is_changed => false,
				:change_message => ""
			)
			query.save!
			query
		end

		def update_name(query_info, user)
			query = Query.find(query_info[:id])
			unless Permissions.user_can_delete_query?(user, query)
				raise PayloadException.access_denied "you do not have permissions to save this query"
			end
			query.update_attributes!(
					:name => query_info[:name],
					:editor => user
			)
			query
		end

		def update_permissions(query_info, user)
			query = Query.find(query_info[:id])
			unless Permissions.user_can_update_query_permissions?(user, query)
				raise PayloadException.access_denied "you do not have permissions to save this query"
      end
			query.update_attributes!(
				:is_shared => query_info[:isShared],
				:editor => user
			)
      query
		end

		def create(query_info, project, user, save=false)
			query = Query.new(
					:owner => user,
					:editor => user,
					:project => project,
					:name => query_info[:name],
					:is_shared => query_info[:isShared],
					:conjunction => query_info[:conjunction],
					:is_changed => false,
					:change_message => ""
				)
			if save
				query.save!
			end
			query
		end

		def create_param (param_info, project_id, save=false)
			form = nil
			unless param_info[:formName].nil?
				form = FormStructure.find_by(:project_id => project_id, :name => param_info[:formName])
			end
			question = nil
			if param_info[:isManyToOneInstance] == false and param_info[:isManyToOneCount] == false
				unless param_info[:questionName].nil? or form.nil?
					question = FormQuestion.find_by(:form_structure_id => form.id, :variable_name => param_info[:questionName])
				end
			end
			# TODO: add different exception types
			value = param_info[:value]

			param = QueryParam.new(
			  :form_structure => form,
				:form_question => question,
				:value => value,
				:operator => param_info[:operator],
				:sequence_number => param_info[:sequenceNum],
				:is_last => param_info[:isLast],
				:is_many_to_one_instance => param_info[:isManyToOneInstance],
				:is_many_to_one_count => param_info[:isManyToOneCount],
				:is_regular_exception => false,
				:is_year_exception => false,
				:is_month_exception => false,
				:is_day_exception => false
				)

			if question != nil
				if question.question_type == "date"
					handle_date_exception(param, question)
				else
					handle_regular_exception(param, question)
				end
			end

			if save
				param.save!
			end
			param
		end

		def handle_date_exception(param, question)
			date_parts = param.value.split("/")
			if date_parts.length != 3
				return
			end
			day = date_parts[1]
			month = date_parts[0]
			year = date_parts[2]
			question.question_exceptions.each do |exception|
				if exception.exception_type == "date_day" and day == exception.value
					param.is_day_exception = true
				elsif exception.exception_type == "date_month" and month == exception.value
					param.is_month_exception = true
				elsif exception.exception_type == "date_year" and year == exception.value
					param.is_year_exception = true
				end
			end
		end

		def handle_regular_exception(param, question)
			question.question_exceptions.each do |exception|
				if exception.value == param.value
					param.is_regular_exception = true
				end
			end
		end
	end
end