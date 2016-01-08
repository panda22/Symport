class ProjectCreator
  class << self
    def create(user, project_data, is_demo=false)
      if is_demo
        project = Project.create! name: "Demo Project", is_demo: true
      else
        project = Project.create! name: project_data[:name].try(:strip), attribution: project_data[:attribution].try(:strip)
      end
      team_member = TeamMember.create!({
        user: user,
        project: project,
        administrator: true,
        form_creation: true,
        audit: true,
        export: true,
        view_personally_identifiable_answers: true,
      })

      AuditLogger.add(user, project)
      AuditLogger.add(user, team_member)

      project
    end
  end
end
