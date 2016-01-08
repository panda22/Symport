class ProjectLevelPermissionsSerializer
  class << self
    def serialize(user, project)
      {
        editSettings: Permissions.user_can_edit_project_settings?(user, project),
        createForms: Permissions.user_can_create_forms_in_project?(user, project),
        deleteProject: Permissions.user_can_delete_project?(user, project),
        renameSubjectIDs: Permissions.user_can_rename_subject_ids_in_project?(user, project),
      }
    end
  end
end
