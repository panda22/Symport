describe ProjectCreator do
  subject { described_class }
  before do
    mock_class TeamMemberCreator
  end
  describe '.create' do
    it 'creates a new Project record' do
      project_record = subject.create User.new, name: "Cool Project"
      Project.find(project_record.id).name.should == "Cool Project"
    end

    it 'removes all leading and trailing spaces from project name before trying to create project' do
      name_with_leading_and_trailing_spaces = "        Cool Project         "
      project_record = subject.create User.new, name: name_with_leading_and_trailing_spaces
      project_record.name.should == "Cool Project"
    end

    it 'initializes the team for a new Project' do
      user = create :user, email: "hello@world.com", password: "Complex1"
      project = subject.create user, name: "Ice Cold Project"
      project.reload.team_members.count.should == 1
      project.reload.team_members[0].administrator.should be_true
      project.reload.team_members[0].form_creation.should be_true
      project.reload.team_members[0].audit.should be_true
      project.reload.team_members[0].export.should be_true
      project.reload.team_members[0].view_personally_identifiable_answers.should be_true
      project.reload.team_members[0].user.should == user
    end

    it "logs the creation of project and initial team member" do
      user = create :user, email: "blah@blah.com", password: "Complex1"

      saw_project = false
      saw_team_member = false
      AuditLogger.stubs(:add).with do |editor, record|
         if (editor == user)
          if (record.is_a?(Project) && record.name == "My Cool Project")
            saw_project = true
            true
          elsif (record.is_a?(TeamMember) && record.user == user)
            saw_team_member = true
            true
          else
            false
          end
         else
          false
         end
      end

      project = subject.create user, name: "My Cool Project"
      saw_project.should be_true
      saw_team_member.should be_true
    end
  end
end
