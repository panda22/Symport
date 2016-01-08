class FormLevelPermissionsSerializer
  class << self
    def serialize(user, form_structure)
      project = form_structure.project
      {
        viewData: Permissions.user_can_view_form_responses_for_form_structure?(user, form_structure),
        enterData: Permissions.user_can_enter_form_responses_for_form_structure?(user, form_structure),
        deleteForm: Permissions.user_can_delete_form_structure?(user, form_structure),
        renameForm: Permissions.user_can_create_forms_in_project?(user, project),
        downloadFormData: Permissions.user_can_export_responses_for_project?(user, project),
        buildForm: Permissions.user_can_edit_form_structure?(user, form_structure),
        viewPhiData: Permissions.user_can_view_personally_identifiable_answers_for_project?(user, project)
      }
    end
  end
end
