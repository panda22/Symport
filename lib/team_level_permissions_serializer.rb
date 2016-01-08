class TeamLevelPermissionsSerializer
  class << self
    def serialize(user, project)
      {
        addTeamMember: Permissions.user_can_edit_teams_in_project?(user, project),
        removeTeamMember: Permissions.user_can_edit_teams_in_project?(user, project),
        editTeamMember: Permissions.user_can_edit_teams_in_project?(user, project),
        viewTeamMember: Permissions.user_can_see_project?(user, project)
      }
    end
  end
end
