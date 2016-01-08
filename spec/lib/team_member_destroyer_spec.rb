describe TeamMemberDestroyer do
  subject { described_class }

  before do
    Permissions.stubs(:user_can_edit_teams_in_project?).returns true
    mock_class AuditLogger
  end

  describe ".remove_team_member" do
    let (:project) { Project.create name: "dropping like flies" }
    let (:user_1) { create :user, email: "user1@users.com", password: "Complex1" }
    let (:user_2) { create :user, email: "user2@users.com", password: "Complex1" }
    let (:user_3) { create :user, email: "user3@users.com", password: "Complex1" }
    let (:current_user) { User.new }

    it "deletes a team member from the project based on id" do
      team_member_1 = TeamMember.create user: user_1, project: project, administrator: true
      team_member_2 = TeamMember.create user: user_2, project: project, administrator: true
      team_member_3 = TeamMember.create user: user_3, project: project
      project.reload
      subject.remove_team_member(current_user, project, team_member_2)
      project.reload.team_members.should =~ [team_member_1, team_member_3]
    end

    it 'logs deletion of a team member from the project' do
      team_member_1 = TeamMember.create user: user_1, project: project, administrator: true
      team_member_2 = TeamMember.create user: user_2, project: project, administrator: true
      team_member_3 = TeamMember.create user: user_3, project: project

      AuditLogger.expects(:remove).with(current_user, team_member_2)

      project.reload
      subject.remove_team_member(current_user, project, team_member_2)
    end

    it "raises an error when team member does not exist" do
      team_member_1 = TeamMember.create user: user_1, project: project, administrator: true
      team_member_2 = TeamMember.create user: user_2, project: project, administrator: true
      team_member_3 = TeamMember.create user: user_3, project: Project.create
      project.reload
      expect {
        subject.remove_team_member(current_user, project, team_member_3)
      }.to raise_error { |error|
        error.error[:validations][:email].should == "Team member user3@users.com is not in project"
      }
    end

    it "refuses to remove team member if only administrator" do
      team_member_1 = TeamMember.create user: user_1, project: project
      team_member_2 = TeamMember.create user: user_2, project: project, administrator: true
      team_member_3 = TeamMember.create user: user_3, project: project
      project.reload
      expect {
        subject.remove_team_member(current_user, project, team_member_2)
      }.to raise_error { |error|
        error.error[:validations][:administrator].should == "Team member user2@users.com may not be deleted because they are the only administrator"
      }
    end

    it "has to delete all form structure permissions" do
      form_structure_1 = FormStructure.create! name: "Form1", project: project
      form_structure_2 = FormStructure.create! name: "Form2", project: project
      team_member = TeamMember.create user: user_1, project: project

      perm1 = FormStructurePermission.create! team_member: team_member,
        form_structure: form_structure_1, permission_level: "Full"
      perm2 = FormStructurePermission.create! team_member: team_member,
        form_structure: form_structure_2, permission_level: "Read"

      Permissions.expects(:user_can_edit_teams_in_project?).with(current_user, project).returns true
      team_member.form_structure_permissions = [perm1, perm2]
      perm1.deleted_at.should be_nil
      perm2.deleted_at.should be_nil

      subject.remove_team_member(current_user, project, team_member)
      perm1.reload.deleted_at.should_not be_nil
      perm2.reload.deleted_at.should_not be_nil
    end

    it "refuses to delete if lacking permissions" do
      team_member_1 = TeamMember.create user: user_1, project: project
      Permissions.expects(:user_can_edit_teams_in_project?).with(current_user, project).returns false
      expect {
        subject.remove_team_member(current_user, project, team_member_1)
      }.to raise_error { |error|
        error.status == 403
      }
    end

    it "allows to remove team member if removing project flag is set" do
      team_member_1 = TeamMember.create user: user_1, project: project
      team_member_2 = TeamMember.create user: user_2, project: project, administrator: true
      team_member_3 = TeamMember.create user: user_3, project: project
      project.reload
      subject.remove_team_member(current_user, project, team_member_2, true)
      project.reload.team_members.should =~ [team_member_1, team_member_3]
    end
  end
end
