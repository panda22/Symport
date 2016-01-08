describe ProjectTeamSerializer do
  subject { described_class }
  describe '.serialize' do
    let (:project) { Project.create name: "No 'I' in team" }
    let (:user1) { create :user, email: "dq@dq.com", password: "Complex1" }
    let (:user2) { create :user, email: "dq1@dq.com", password: "Complex1" }
    let (:user3) { create :user, email: "dq2@dq.com", password: "Complex1" }
    let (:team_member_1) { TeamMember.create administrator: true, user: user1 }
    let (:team_member_2) { TeamMember.create expiration_date: Date.parse("Oct 11, 2014"), user: user2 }
    let (:team_member_3) { TeamMember.create form_creation: true, audit: true, user: user3 }

    before do
      mock_class TeamMemberSerializer
      mock_class FormStructurePermissionSerializer
      project.team_members = [team_member_1, team_member_2, team_member_3]
      project.save!
    end

    it 'serializes the team members in the project' do
      TeamMemberSerializer.expects(:serialize).with(user1, team_member_1).returns("member 1")
      TeamMemberSerializer.expects(:serialize).with(user1, team_member_2).returns("member 2")
      TeamMemberSerializer.expects(:serialize).with(user1, team_member_3).returns("member 3")
      output = ProjectTeamSerializer.serialize(user1, project)
      output[:teamMembers].should == [ "member 1", "member 2", "member 3" ]
    end

    it "serializes team member permissions" do
      TeamLevelPermissionsSerializer.expects(:serialize).with(user1, project).returns("permissions")
      output = ProjectTeamSerializer.serialize(user1, project)
      output[:userTeamPermissions].should == "permissions"
    end
  end
end
