class FormStructureCreator
  class << self
    def create(data, user, project)
      if !Permissions.user_can_create_forms_in_project?(user, project)
        raise PayloadException.access_denied "You do not have permissions to create forms in this project"
      end
      new_structure = FormRecordCreator.create_structure project, data
      AuditLogger.add(user, new_structure)
      new_structure
    end
  end
end
