describe TeamLevelPermissionsSerializer do
  subject { described_class }
  describe '.serialize' do
    before do
      mock_class Permissions, strict: true
    end
    let(:user) { User.new }
    let (:project) { Project.new }
    it 'serializes add/remove/edit team member permission' do
      Permissions.stubs(:user_can_see_project?).returns false
      Permissions.expects(:user_can_edit_teams_in_project?).with(user, project).returns(false).at_least_once
      subject.serialize(user,project)[:addTeamMember].should be_false
      subject.serialize(user,project)[:removeTeamMember].should be_false
      subject.serialize(user,project)[:editTeamMember].should be_false
      Permissions.expects(:user_can_edit_teams_in_project?).with(user, project).returns(true).at_least_once
      subject.serialize(user,project)[:addTeamMember].should be_true
      subject.serialize(user,project)[:removeTeamMember].should be_true
      subject.serialize(user,project)[:editTeamMember].should be_true
    end

    it 'serializes view team member permission' do
      Permissions.stubs(:user_can_edit_teams_in_project?).returns false
      Permissions.expects(:user_can_see_project?).with(user, project).returns false
      subject.serialize(user,project)[:viewTeamMember].should be_false
      Permissions.expects(:user_can_see_project?).with(user, project).returns true
      subject.serialize(user,project)[:viewTeamMember].should be_true
    end
  end
end
