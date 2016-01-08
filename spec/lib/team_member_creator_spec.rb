describe TeamMemberCreator do
  subject { described_class }

  before do
    mock_class ProjectFormStructuresPermissionsBuilder, strict: true
    ProjectFormStructuresPermissionsBuilder.stubs(:build).returns([])
    Permissions.stubs(:user_can_edit_teams_in_project?).returns true
    mock_class AuditLogger
  end

  describe '.create' do
    let(:creating_user) { User.new }
    let(:project) { Project.create name: "Project A" }
    let(:form_permissions) { [{"first" => "value"}] }
    let(:team_member_data) {
      {
        "email" => "john@smith.com",
        "expirationDate" => "08/29/2020",
        "administrator" => false,
        "formCreation" => true,
        "auditLog" => true,
        "export" => true,
        "viewPersonallyIdentifiableAnswers" => true,
        "structurePermissions" => form_permissions
      }
    }

    it "creates a new team member on the project" do
      user = create :user, email: "john@smith.com", password: "Complex1"

      team_member = subject.create(team_member_data, creating_user, project)
      team_member.reload
      team_member.project.should ==  project
      team_member.user.should == user

      team_member.administrator.should be_false
      team_member.form_creation.should be_true
      team_member.audit.should be_true
      team_member.export.should be_true
      team_member.view_personally_identifiable_answers.should be_true
    end

    it 'logs creation of a team member' do
      user = create :user, email: 'john@smith.com', password: "Complex1"
      member_data = {
        project: project,
        user: user,
        expiration_date: Date.strptime("08/29/2020", "%m/%d/%Y"),
        administrator: false,
        form_creation: true,
        audit:  true,
        export: true,
        view_personally_identifiable_answers: true
      }

      team_member = TeamMember.new

      TeamRecordCreator.expects(:create_team_member).with(member_data).returns(team_member)
      ProjectFormStructuresPermissionsBuilder.expects(:build).with(creating_user, project, team_member, team_member_data['structurePermissions'])
      AuditLogger.expects(:add).with(creating_user, team_member)
      subject.create(team_member_data, creating_user, project)
    end

    it "creates a new team member on the project when the team member is administrator" do
      user = create :user, email: "john@smith.com", password: "Complex1"
      alternate_team_member_data = {
        "email" => "john@smith.com",
        "expirationDate" => "08/29/2020",
        "administrator" => true,
        "formCreation" => false,
        "auditLog" => false,
        "export" => false,
        "viewPersonallyIdentifiableAnswers" => false
      }

      team_member = subject.create(alternate_team_member_data, creating_user, project)
      team_member.reload

      team_member.expiration_date.should be_nil
      team_member.administrator.should be_true
      team_member.form_creation.should be_true
      team_member.audit.should be_true
      team_member.export.should be_true
      team_member.view_personally_identifiable_answers.should be_true
    end

    #it "raises an error when user is not in system" do  SHOULD TURN INTO INVITE NEW USER
    #  expect { subject.create(team_member_data, creating_user, project) }.to raise_error { |err|
    #    err.error[:validations][:email].should == "User john@smith.com is not in the system"
    #  }
    #end

    it "raises an error when user is already on the team" do
      john = create :user, email: "john@smith.com", password: "Complex1"
      project.team_members << TeamMember.create(user: john)
      expect { subject.create(team_member_data, creating_user, project) }.to raise_error { |err|
        err.error[:validations][:email].should == "User john@smith.com is already on the team"
      }
    end

    it "raises an error when date is provided but is invalid" do
      john = create :user, email: "john@smith.com", password: "Complex1"
      team_member_data["expirationDate"] = "invalid date"
      expect { subject.create(team_member_data, creating_user, project) }.to raise_error { |err|
        err.error[:validations][:expirationDate].should == "invalid date is not in the correct format"
      }
    end

    it "allows empty expiration date" do
      john = create :user, email: "john@smith.com", password: "Complex1"
      team_member_data["expirationDate"] = ""

      team_member = subject.create(team_member_data, creating_user, project)
      team_member.reload
      team_member.project.should ==  project
      team_member.user.should == john
    end

    it 'rejects creating if user lacks permissions' do
      Permissions.stubs(:user_can_edit_teams_in_project?).with(creating_user, project).returns false
      expect { subject.create(team_member_data, creating_user, project) }.to raise_error PayloadException
    end
  end
end
