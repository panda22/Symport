class TeamMembersController < ApplicationController
  def create
    project = ProjectLookup.find_project(current_user, params[:project_id])
    team_member = TeamMemberCreator.create(params[:team_member], current_user, project)
    render json: { teamMember: TeamMemberSerializer.serialize(current_user, team_member) }
  end

  def index
    project = ProjectLookup.find_project current_user, params[:project_id]
    render json: { project: ProjectTeamSerializer.serialize(current_user, project) }
  end

  def destroy
    project = ProjectLookup.find_project(current_user, params[:project_id])
    team_member = ProjectLookup.find_team_member(current_user, params[:id])
    TeamMemberDestroyer.remove_team_member(current_user, project, team_member)
    render json: { project: ProjectTeamSerializer.serialize(current_user, project) }
  end

  def update
    team_member = ProjectLookup.find_team_member(current_user, params[:id])
    updated_team_member = TeamMemberUpdater.update(params[:team_member], current_user, team_member)
    render json: { teamMember: TeamMemberSerializer.serialize(current_user, updated_team_member) }
  end
end
