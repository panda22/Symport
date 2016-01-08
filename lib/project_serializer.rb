class ProjectSerializer
  class << self
    def serialize(user, project, include_structures)
      ShallowRecordSerializer.serialize(project, :id, :name, :is_demo, :attribution).tap do |proj|
        proj[:lastEdited] = project.updated_at
        proj[:formsCount] = project.form_structures.count
        proj[:subjectsCount] = project.form_responses.select(:subject_id).distinct.count
        proj[:userPermissions] = ProjectLevelPermissionsSerializer.serialize(user, project)
        proj[:administratorNames] = project.administrators.map do |admin| 
          admin.user.try :full_name 
        end.reject(&:blank?).join(", ")
        if include_structures
          proj[:structures] = project.form_structures.map do |structure|
            FormStructureSerializer.serialize(user, structure, false)
          end
        end
        if proj[:isDemo]
          demo_progress = DemoProgress.where(user_id: user.id, project_id: project.id)[0]
          proj[:demoProgress] = ShallowRecordSerializer.serialize(
            demo_progress,
            :id,
            :demo_form_id,
            :demo_question_id,
            :project_index_global,
            :project_index_demo_project,
            :form_enter_edit,
            :enter_edit_subject_id,
            :enter_edit_response,
            :enter_edit_save,
            :data_tab_emphasis,
            :view_data_sort_search,
            :create_new_query,
            :build_query_info,
            :build_query_params,
            :query_results_download,
            :query_results_breadcrumbs,
            :form_global,
            :team_button,
            :add_new_team_member,
            :add_team_member_personal_details,
            :add_team_member_project_permissions,
            :add_team_member_form_permissions,
            :import_button,
            :import_overlays,
            :import_csv_text,
            :build_form_button,
            :form_builder_info,
            :build_form_add_question,
            :question_builder_prompt,
            :question_builder_variable,
            :question_builder_identifying
            )
        end
      end
    end
  end
end
