describe TeamMembersController do
  before do
    sign_in
    @user = controller.current_user
  end

  describe '#create' do
    it 'creates a new team member for the project' do
      project = Project.new name: "Project A"
      team_member_data = {
        "email" => "john@smith.com",
        "expirationDate" => "some date"
      }
      team_member = mock "team member"
      ProjectLookup.expects(:find_project).with(@user, "1234").returns(project)
      TeamMemberCreator.expects(:create).with(team_member_data, @user, project).returns(team_member)
      TeamMemberSerializer.expects(:serialize).with(@user, team_member).returns("serialized team member")

      post :create, project_id: "1234", team_member: team_member_data, format: :json
      response.should be_success
      response.body.should == {teamMember: "serialized team member"}.to_json
    end
  end

  describe '#update' do
    it "updates an existing team member of the project" do
      team_member = mock "existing team member"
      team_member_data = "New Information for Existing Team Member"
      updated_team_member = mock "updated team member"

      ProjectLookup.expects(:find_team_member).with(@user, "111").returns(team_member)
      TeamMemberUpdater.expects(:update).with(team_member_data, @user, team_member).returns(updated_team_member)
      TeamMemberSerializer.expects(:serialize).with(@user, updated_team_member).returns("serialized updated team member")

      put :update, project_id: "1234", id: "111", team_member: team_member_data, format: :json
      response.should be_success
      response.body.should == {teamMember: "serialized updated team member"}.to_json
    end
  end

  describe '#destroy' do
    it 'deletes a team member and re-serializes the team' do
      project = Project.new name: "And then there were two"
      team_member = TeamMember.new
      seq = sequence("team member destroy")
      ProjectLookup.expects(:find_project).with(@user, "1234").returns(project)
      ProjectLookup.expects(:find_team_member).with(@user, "abcd").returns(team_member)
      TeamMemberDestroyer.expects(:remove_team_member).with(@user, project, team_member).in_sequence(seq)
      ProjectTeamSerializer.expects(:serialize).with(@user, project).returns(:updated_serialized_team).in_sequence(seq)
      delete :destroy, project_id: "1234", id: "abcd", format: :json
      response.should be_success
      response.body.should == {project: :updated_serialized_team}.to_json
    end
  end

  describe '#index' do
    it 'returns team members for project' do
      team_member1 = TeamMember.new
      team_member2 = TeamMember.new
      project = Project.new name: "no i in team"
      project.team_members = [team_member1, team_member2]
      ProjectLookup.expects(:find_project).with(@user, '1234').returns(project)
      ProjectTeamSerializer.expects(:serialize).with(@user, project).returns("serialized team members")
      get :index, project_id: '1234'
      response.should be_success
      response.body.should == { project: "serialized team members"}.to_json
    end
  end

end
