class FormPermissionCreator
  class << self
    def create(form_structure, data)
      team_member = User.find_by(email: data["userEmail"]).team_members.find_by(project: form_structure.project)

      if team_member.form_structure_permissions.find_by(form_structure: form_structure)
        raise PayloadException.validation_error userEmail: "The team member #{data['userEmail']} has already a permission for this form"
      else
        FormStructurePermission.create!(team_member: team_member, permission_level: data["permissionLevel"],
                                      form_structure: form_structure)
      end
    end
  end
end
