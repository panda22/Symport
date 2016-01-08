describe TeamMemberUpdater do
  subject { described_class }
  before do
    mock_class ProjectFormStructuresPermissionsUpdater, strict: true
    ProjectFormStructuresPermissionsUpdater.stubs(:update)
    Permissions.stubs(:user_can_edit_teams_in_project?).returns true
    AuditLogger.stubs(:surround_edit).yields
  end
  describe '.update' do
    let(:current_user) { User.new }
    let(:project) { Project.create name: "Good Project" }
    let(:user_1) { create :user, email: "dq1@dq.com", password: "Complex1" }
    let(:user_2) { create :user, email: "dq2@dq.com", password: "Complex1" }

    it "updates an existing team member with the new data" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator:true)
      team_member_2 = TeamMember.create(user: user_2, project: project)
      data = {
        "expirationDate" => "08/29/2020",
        "administrator" => false,
        "export" => true,
        "auditLog" => true,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => true
      }

      updated_team_member = subject.update(data, current_user, team_member_2)

      updated_team_member.expiration_date.should == Date.strptime("08/29/2020", "%m/%d/%Y")
      updated_team_member.administrator.should == false
      updated_team_member.export.should ==  true
      updated_team_member.audit.should == true
      updated_team_member.view_personally_identifiable_answers.should == true
    end

    it "logs updating of a team member" do
      team_member_2 = TeamMember.create(user: user_2, project: project)
      data = {
        "expirationDate" => "08/29/2020",
        "administrator" => false,
        "export" => true,
        "auditLog" => true,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => true
      }

      AuditLogger.expects(:surround_edit).with(current_user, team_member_2).yields
      subject.update(data, current_user, team_member_2)
    end

    it "sets other permissions and expiration date based on admin flag" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator:true)
      team_member_2 = TeamMember.create(user: user_2, project: project, expiration_date: Date.strptime("08/29/2020", "%m/%d/%Y"))
      data = {
        "expirationDate" => "08/29/2020",
        "administrator" => true,
        "export" => false,
        "auditLog" => false,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => false
      }

      updated_team_member = subject.update(data, current_user, team_member_2)

      updated_team_member.expiration_date.should be_nil
      updated_team_member.administrator.should be_true
      updated_team_member.export.should be_true
      updated_team_member.audit.should be_true
      updated_team_member.view_personally_identifiable_answers.should be_true
    end

    it "allows editing only administrator if member remains an admin" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator: true)
      team_member_2 = TeamMember.create(user: user_2, project: project)

      data = {
        "expirationDate" => "08/29/2020",
        "administrator" => true,
        "export" => true,
        "auditLog" => true,
        "formCreation" => true,
        "viewPersonallyIdentifiableAnswers" => true
      }

      updated_team_member = subject.update(data, current_user, team_member_1)

      updated_team_member.expiration_date.should be_nil
      updated_team_member.administrator.should == true
      updated_team_member.export.should ==  true
      updated_team_member.audit.should == true
      updated_team_member.view_personally_identifiable_answers.should == true
    end

    it "prevents clearing administrator flag if current team member is the only administrator" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator: true)
      team_member_2 = TeamMember.create(user: user_2, project: project)

      data = {
        "expirationDate" => "08/29/2020",
        "administrator" => false,
        "export" => true,
        "auditLog" => true,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => true
      }

      expect { subject.update(data, current_user, team_member_1) }.to raise_error { |err|
        err.error[:validations][:administrator].should == "Changing the role of the only administrator on the project is not possible"
      }

    end

    it "prevents clearing administrator flag on yourself" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator: true)
      team_member_2 = TeamMember.create(user: user_2, project: project)
      Permissions.expects(:user_can_edit_teams_in_project?).with(user_1, project).returns(true)

      data = {
        "expirationDate" => "08/29/2020",
        "administrator" => false,
        "export" => true,
        "auditLog" => true,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => true
      }

      expect { subject.update(data, user_1, team_member_1) }.to raise_error { |err|
        err.error[:validations][:administrator].should == "You may not remove administrator permissions on yourself"
      }

    end

    it "accepts empty expiration date" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator: true, expiration_date: 1.day.from_now)

      data = {
        "administrator" => true,
        "export" => true,
        "auditLog" => true,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => true
      }
      updated_team_member = subject.update(data, current_user, team_member_1)
      updated_team_member.expiration_date.should be_nil
    end

    it "rejects invalid expiration date" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator: false, expiration_date: 1.day.from_now)

      data = {
        "expirationDate" => "invalid date",
        "administrator" => false,
        "export" => true,
        "auditLog" => true,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => true
      }
      expect { subject.update(data, current_user, team_member_1) }.to raise_error { |err|
        err.error[:validations][:expirationDate].should == "invalid date is not in the correct format"
      }

    end

    it "updates the form structure permissions" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator: true, expiration_date: 1.day.from_now)

      data = {
        "administrator" => true,
        "export" => true,
        "auditLog" => true,
        "formCreation" => false,
        "viewPersonallyIdentifiableAnswers" => true,
        "structurePermissions" => ['a', 'b', 'c']
      }
      ProjectFormStructuresPermissionsUpdater.expects(:update).with(current_user, team_member_1, ['a', 'b', 'c'])
      updated_team_member = subject.update(data, current_user, team_member_1)
    end

    it "rejects update when lacking permissions" do
      team_member_1 = TeamMember.create(user: user_1, project: project, administrator: true, expiration_date: 1.day.from_now)
      data = {
        "administrator" => true,
      }
      Permissions.expects(:user_can_edit_teams_in_project?).with(current_user, project).returns false
      expect { subject.update(data, current_user, team_member_1) }.to raise_error PayloadException
    end

    describe "updating form permissions and team member attributes in a transaction" do
      it "rejects all changes (including auditing) when permissions updating fails" do
        team_member_1 = TeamMember.create(user: user_1, project: project, administrator:true)
        team_member_2 = TeamMember.create(user: user_2, project: project)
        data = {
          "expirationDate" => "08/29/2020",
          "administrator" => false,
          "export" => true,
          "auditLog" => true,
          "formCreation" => false,
          "viewPersonallyIdentifiableAnswers" => true,
          "structurePermissions" => 'perms'
        }
        ProjectFormStructuresPermissionsUpdater.expects(:update).with(current_user, team_member_2, 'perms').raises PayloadException.validation_error("foo")

        expect { subject.update(data, current_user, team_member_2) }.to raise_error PayloadException
        team_member_2.reload.expiration_date.should be_nil
      end

      it "rejects all changes (including auditing) when team member updating fails" do
        team_member_1 = TeamMember.create(user: user_1, project: project, administrator:true)
        team_member_2 = TeamMember.create(user: user_2, project: project)
        data = {
          "expirationDate" => "08/29/2020",
          "administrator" => :banana,
        }
        ProjectFormStructuresPermissionsUpdater.stubs(:update)
        team_member_2.stubs(:update_attributes!).raises ActiveRecord::RecordInvalid.new team_member_2

        expect { subject.update(data, current_user, team_member_2) }.to raise_error ActiveRecord::RecordInvalid
        team_member_2.reload.expiration_date.should be_nil
      end
    end
  end
end
