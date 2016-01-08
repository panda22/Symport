class ProjectDestroyer
  class << self
    def destroy(user, project)
      if !Permissions.user_can_delete_project?(user, project)
        raise PayloadException.access_denied "You do not have permission to delete this project"
      end
      Query.where(:project_id => project.id).destroy_all
      project.form_structures.each { |structure| FormStructureDestroyer.destroy(user, structure) }
      project.team_members.each { |team_member| TeamMemberDestroyer.remove_team_member(user, project, team_member, true) }
      project.destroy
      AuditLogger.remove(user, project)
    end
  end
end