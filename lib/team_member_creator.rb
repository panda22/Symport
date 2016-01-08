class TeamMemberCreator
  class << self
    def create(team_member_data, creating_user, project)
      if !Permissions.user_can_edit_teams_in_project?(creating_user, project)
        raise PayloadException.access_denied "You do not have permissions to add team members"
      end
      user = User.find_by email: team_member_data["email"].try(:downcase).try(:strip)
      if user
        begin
          administrator_flag = team_member_data["administrator"]
          form_creation_flag = administrator_flag || team_member_data["formCreation"]
          audit_flag = administrator_flag || team_member_data["auditLog"]
          export_flag = administrator_flag || team_member_data["export"]
          view_personally_identifiable_answers_flag = administrator_flag || team_member_data["viewPersonallyIdentifiableAnswers"]
          begin
            if !administrator_flag and team_member_data["expirationDate"].present?
              expiration_date = Date.strptime(team_member_data["expirationDate"], "%m/%d/%Y")
            end
          rescue
            raise PayloadException.validation_error(expirationDate:
                "#{team_member_data['expirationDate']} is not in the correct format")
          end
          team_member = TeamRecordCreator.create_team_member(
                                         project: project, user: user,
                                         expiration_date: expiration_date,
                                         administrator: administrator_flag,
                                         form_creation: form_creation_flag,
                                         audit: audit_flag,
                                         export: export_flag,
                                         view_personally_identifiable_answers: view_personally_identifiable_answers_flag
                                        )

          ProjectFormStructuresPermissionsBuilder.build(creating_user, project, team_member, team_member_data['structurePermissions'])
          AuditLogger.add(creating_user, team_member)

          team_member
        rescue ActiveRecord::RecordInvalid => error
          raise PayloadException.validation_error email: "User #{team_member_data['email']} is already on the team"
        end
      else
        if team_member_data['email'] == "" or team_member_data['email'] == nil
          raise PayloadException.validation_error({email: "Please specify an email address"})
        end
        cur_team_member = TeamMember.where("user_id='#{creating_user.id}' and project_id='#{project.id}'").first
        valid_email_regex = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        begin
          is_valid_email = team_member_data['email'].try(:downcase).try(:strip).match(valid_email_regex) != nil
        rescue
          raise PayloadException.validation_error({email: "#{team_member_data['email']} is not a valid email address",
                                                   canCreateNewUser: false})
        end
        administrator_flag = team_member_data["administrator"]
        #if !administrator_flag and team_member_data["expirationDate"].present? == false
        #  raise PayloadException.validation_error(expirationDate:
        #        "#{team_member_data['expirationDate']} must be entered")
        #end
        if is_valid_email
          can_create_new_user = (cur_team_member.administrator)
          raise PayloadException.validation_error({email: "#{team_member_data['email']} is not a Symport user",
                                                canCreateNewUser: can_create_new_user})
        else
          raise PayloadException.validation_error({email: "#{team_member_data['email']} is not a valid email address",
                                                   canCreateNewUser: false})
        end
      end
    end
  end
end
