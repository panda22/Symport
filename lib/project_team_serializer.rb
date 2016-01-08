class ProjectTeamSerializer
  class << self
    def serialize(user, project)
      { 
         teamMembers: project.team_members.map do |member| 
            TeamMemberSerializer.serialize user, member
         end,
         userTeamPermissions: TeamLevelPermissionsSerializer.serialize(user, project)
      }
    end
  end
end
