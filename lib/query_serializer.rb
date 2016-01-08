class QuerySerializer
	class << self
		def serialize(query, user)
			params = query.query_params.map do |param|
				QuerySerializer.serialize_param(param)
			end
			forms = QuerySerializer.serialize_query_forms(query.project_id, query.query_form_structures, user)
			#result =
			owner_name = "Me"
			if query.owner.id != user.id
				owner_name = query.owner.first_name + " " + query.owner.last_name
			end
			editor_name = "Me"
			if query.editor.id != user.id
				editor_name = query.editor.first_name + " " + query.editor.last_name
			end
			{
				:id => query.id,
				:projectID => query.project_id,
				:ownerName => owner_name,
				:editorName => editor_name,
				:name => query.name,
				:created => query.created_at,
				:edited => query.updated_at,
				:isShared => query.is_shared,
				:conjunction => query.conjunction,
				:canEditPermissions => Permissions.user_can_update_query_permissions?(user, query),
				:canDelete => Permissions.user_can_delete_query?(user, query),
				:queriedForms => forms,
				:queryParams => params,
				:isChanged => (query.is_changed == nil) ? false : query.is_changed,
				:changeMessage => query.change_message
			}
			#project = Project.find(query.project_id)
			#project.form_structures.pluck(:id).each do |form_id|
			#	result[:queriedForms][form_id] = query.query_form_structures.include?(form_id)
			#end
			#result
		end

		def serialize_param(param)
			form = param.form_structure
			type = ""
			name = ""
			if param.is_many_to_one_count
				type = "numericalrange"
				name = "number of #{form.secondary_id}"
			elsif param.is_many_to_one_instance
				type = "text"
				name = form.secondary_id
			else
				type = param.form_question.question_type
				name = param.form_question.variable_name
			is_exception = param.is_regular_exception or param.is_day_exception or param.is_month_exception or param.is_year_exception
			end
			{
				:id => param.id,
				:operator => param.operator,
				:value => param.value,
				:formName => form.name,
				:questionName => name,
				:questionType => type,
				:sequenceNum => param.sequence_number,
				:isLast => param.is_last,
				:isException => is_exception,
				:isManyToOneInstance => param.is_many_to_one_instance,
				:isManyToOneCount => param.is_many_to_one_count
			}
		end

		def serialize_query_forms(project_id, query_forms, user)
			forms = query_forms.pluck(:form_structure_id)
			Project.find(project_id).form_structures.map do |form|
				{
					formID: form.id,
					formName: form.name,
					included: forms.include?(form.id),
					displayed: Permissions.user_can_view_form_responses_for_form_structure?(user, form)
				}
			end
		end
	end
end