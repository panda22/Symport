class ProjectLookup
  class << self

    def find_project(current_user, id)
      project = Project.find(id)
      if !Permissions.user_can_see_project? current_user, project
        raise PayloadException.access_denied "You do not have access to this project"
      end
      project
    end

    def find_projects_for_user(user)
      if user.nil?
        []
      elsif user.super_user
        Project.where(is_demo: false)
      else
        user.projects
      end
    end

    def find_team_member(current_user, id)
      team_member = TeamMember.find(id)
      project = team_member.project
      if !Permissions.user_can_see_project? current_user, project
        raise PayloadException.access_denied "You do not have access to this team member"
      end
      team_member
    end

    def find_project_for_response(form_response)
      form_response.form_structure.project
    end

  end
end
