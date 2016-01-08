class TeamMemberUpdater
  class << self
    def update(data, current_user, team_member)
      if !Permissions.user_can_edit_teams_in_project? current_user, team_member.project
        raise PayloadException.access_denied "You do not have permissions to update team members on this project"
      end
      administrator_flag = data["administrator"]
      if team_member.user == current_user and team_member.administrator and !administrator_flag
        raise PayloadException.validation_error administrator: "You may not remove administrator permissions on yourself"
      elsif !administrator_flag and team_member.project.administrators == [team_member]
        raise PayloadException.validation_error administrator: "Changing the role of the only administrator on the project is not possible"
      end
      form_creation_flag = administrator_flag || data["formCreation"]
      audit_flag = administrator_flag || data["auditLog"]
      export_flag = administrator_flag || data["export"]
      view_personally_identifiable_answers_flag = administrator_flag || data["viewPersonallyIdentifiableAnswers"]
      begin
        if !administrator_flag and data["expirationDate"].present?
          expiration_date = Date.strptime(data["expirationDate"], "%m/%d/%Y")
        end
      rescue
        raise PayloadException.validation_error(expirationDate:
          "#{data['expirationDate']} is not in the correct format")
      end

      TeamMember.transaction do
        ProjectFormStructuresPermissionsUpdater.update(current_user, team_member, data['structurePermissions'])
        AuditLogger.surround_edit(current_user, team_member) do
          team_member.update_attributes!(expiration_date: expiration_date,
                                         administrator: administrator_flag,
                                         export: export_flag,
                                         audit: audit_flag,
                                         form_creation: form_creation_flag,
                                         view_personally_identifiable_answers: view_personally_identifiable_answers_flag)
        end
        team_member
      end
    end
  end
end
