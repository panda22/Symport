class Permissions
  class << self
    def form_structure_permission_levels
      ["Full", "Read/Write", "Read", "None"]
    end

    def user_can_see_project?(user, project)
      user.super_user or user.team_members.find_by(project: project).present?
    end

    def user_can_delete_project?(user, project)
      pass_project_permission(user, project, :administrator)
    end

    def user_can_rename_subject_ids_in_project?(user, project)
      pass_project_permission user, project, :administrator
    end

    def user_can_edit_project_settings?(user, project)
      pass_project_permission(user, project, :administrator)
    end

    def user_can_edit_teams_in_project?(user, project)
      pass_project_permission(user, project, :administrator)
    end

    def user_can_create_forms_in_project?(user, project)
      pass_project_permission(user, project, :form_creation)
    end

    def user_can_access_audit_log_for_project?(user, project)
      pass_project_permission(user, project, :audit)
    end

    def user_can_export_responses_for_project?(user, project)
      pass_project_permission(user, project, :export)
    end

    def user_can_view_personally_identifiable_answers_for_project?(user, project)
      pass_project_permission(user, project, :view_personally_identifiable_answers)
    end

    def user_can_see_form_structure?(user, form_structure)
      pass_form_structure_permission(user, form_structure, "Read")
    end

    def user_can_edit_form_structure?(user, form_structure)
      pass_form_structure_permission(user, form_structure, "Full")
    end

    def user_can_delete_form_structure?(user, form_structure)
      pass_project_permission(user, form_structure.project, :administrator)
    end

    def user_can_enter_form_responses_for_form_structure?(user, form_structure)
      pass_form_structure_permission(user, form_structure, "Read/Write")
    end

    def user_can_delete_form_responses_for_form_structure?(user, form_structure)
      pass_form_structure_permission(user, form_structure, "Read/Write")
    end

    def user_can_view_form_responses_for_form_structure?(user, form_structure)
      pass_form_structure_permission(user, form_structure, "Read")
    end

    def user_can_view_query?(user, query)
      pass_query_permission(user, query, "view")
    end

    def user_can_update_query?(user, query)
      pass_query_permission(user, query, "edit")
    end

    def user_can_update_query_permissions?(user, query)
      pass_query_permission(user, query, "edit_permissions")
    end

    def user_can_delete_query?(user, query)
      pass_query_permission(user, query, "delete")
    end

    private
    def pass_form_structure_permission(user, form_structure, match_level)
      team_member = user.team_members.find_by project: form_structure.project
      return true if user.super_user
      return true if team_member.present? && team_member.administrator
      return false if !team_member.nil? and team_member.expired?
      current_permissions = user.form_structure_permissions.find_by(form_structure: form_structure)
      return ((current_permissions.present? and form_structure_permission_levels.index(current_permissions.permission_level) <= form_structure_permission_levels.index(match_level)))
    end

    private
    def pass_project_permission(user, project, permission)
      team_member = user.team_members.find_by(project: project)
      return true if user.super_user
      return false if !team_member.nil? and team_member.expired?
      return ((!team_member.nil? and (team_member.administrator or (permission != :administrator and team_member.send permission))))
    end

    def pass_query_permission (user, query, action) # actions are "view", "edit", "edit_permissions", "delete"
      return true if user.super_user
      return false if query.owner.id != user.id and action == "edit_permissions"
      team_member = TeamMember.find_by(:project_id => query.project_id, :user_id => user.id)
      return false if team_member.nil?
      return true if team_member.administrator and (query.is_shared or query.owner.id == user.id)
      query.query_params.each do |param|
        if param.form_question.nil? == false
          question = param.form_question
          return false if team_member.view_personally_identifiable_answers == false and question.personally_identifiable
          form_permission = FormStructurePermission.find_by(:team_member_id => team_member.id, :form_structure_id => question.form_structure_id)
          return false if form_permission.nil?
          return false if form_permission.permission_level.try(:downcase) == "none"
        end
      end
      return false if query.owner.id != user.id and action == "delete"
      return true if query.is_shared or user.id == query.owner.id
      return false
    end
  end
end
