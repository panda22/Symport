describe ProjectDestroyer do
  subject { described_class }

  before do
    mock_class :FormStructureDestroyer
    mock_class :TeamMemberDestroyer
  end

  let (:project) { Project.create(name: "MyProject") }
  let (:current_user) { User.new }

  describe ".destroy" do
    it "destroys a project" do
      user_1 = create :user, email: "user1@users.com", password: "Complex1"
      user_2 = create :user, email: "user2@users.com", password: "Complex1"
      user_3 = create :user, email: "user3@users.com", password: "Complex1"
      team_member_1 = TeamMember.create user: user_1, project: project
      team_member_2 = TeamMember.create user: user_2, project: project, administrator: true
      team_member_3 = TeamMember.create user: user_3, project: project
      project.team_members << [team_member_1, team_member_2, team_member_3]

      form1 = FormStructure.create(name: "Form1")
      form2 = FormStructure.create(name: "Form2")
      form3 = FormStructure.create(name: "Form3")
      project.form_structures << [form1, form2, form3]

      Permissions.expects(:user_can_delete_project?).with(current_user, project).returns(true)
      FormStructureDestroyer.expects(:destroy).with(current_user, form1)
      FormStructureDestroyer.expects(:destroy).with(current_user, form2)
      FormStructureDestroyer.expects(:destroy).with(current_user, form3)
      TeamMemberDestroyer.expects(:remove_team_member).with(current_user, project, team_member_1, true)
      TeamMemberDestroyer.expects(:remove_team_member).with(current_user, project, team_member_2, true)
      TeamMemberDestroyer.expects(:remove_team_member).with(current_user, project, team_member_3, true)
      project.deleted_at.should be_nil

      subject.destroy(current_user, project)

      project.deleted_at.should_not be_nil
    end

    it 'logs deletion of a project' do
      Permissions.expects(:user_can_delete_project?).with(current_user, project).returns(true)
      AuditLogger.expects(:remove).with(current_user, project)
      subject.destroy(current_user, project)
    end
  end
end