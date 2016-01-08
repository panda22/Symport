class TeamMemberDestroyer
  class << self
    def remove_team_member(current_user, project, team_member, removing_project=false)
      if !Permissions.user_can_edit_teams_in_project? current_user, project
        raise PayloadException.access_denied "You do not have permissions to remove users from this project"
      end
      if !project.team_members.include? team_member
        raise PayloadException.validation_error email: "Team member #{team_member.user.email} is not in project"
      elsif !removing_project && project.administrators == [team_member]
        raise PayloadException.validation_error administrator: "Team member #{team_member.user.email} may not be deleted because they are the only administrator"
      end
      # TODO why is this required?
      #team_member.form_structure_permissions.each(&:destroy)
      team_member.destroy
      AuditLogger.remove(current_user, team_member)
    end
  end
end
