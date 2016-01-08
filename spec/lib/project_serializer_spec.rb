describe ProjectSerializer do
  subject { described_class }

  before do
    mock_class ProjectLevelPermissionsSerializer
    ProjectLevelPermissionsSerializer.stubs(:serialize).returns({})
  end

  describe '.serialize' do
    let (:resp1_a) { FormResponse.create subject_id: 'abc' }
    let (:resp1_b) { FormResponse.create subject_id: 'def' }
    let (:resp1_c) { FormResponse.create subject_id: 'ghi' }
    let (:resp2_a) { FormResponse.create subject_id: 'jkl' }
    let (:resp2_b) { FormResponse.create subject_id: 'def' }
    let (:form1) { FormStructure.create name: "Form 1", form_responses: [resp1_a, resp1_b, resp1_c] }
    let (:form2) { FormStructure.create name: "Form 2", form_responses: [resp2_a, resp2_b] }
    let (:project_id) { SecureRandom.uuid }
    let (:project) { Project.create id: project_id, name: "Project-o", form_structures: [form1, form2] }
    let (:user) { User.new }

    it "serializes a project's id" do
      serialized = subject.serialize user, project, false
      serialized[:id].should == project_id
    end

    it "serializes a project's name" do
      serialized = subject.serialize user, project, false
      serialized[:name].should == "Project-o"
    end

    it "serializes a project's permissions for the current user" do
      perms = { a: 'ok' }
      ProjectLevelPermissionsSerializer.expects(:serialize).with(user, project).returns perms
      serialized = subject.serialize user, project, false
      serialized[:userPermissions].should == { a: 'ok' }
    end

    it "serializes a project's forms" do
      FormStructureSerializer.expects(:serialize).with(user, form1, false).returns({'a' => 'b'})
      FormStructureSerializer.expects(:serialize).with(user, form2, false).returns({'c' => 'd'})
      serialized = subject.serialize user, project, true
      serialized[:structures].should == [
        {'a' => 'b'},
        {'c' => 'd'}
      ]
    end

    it "omits a project's forms if not requested" do
      FormStructureSerializer.expects(:serialize).never
      serialized = subject.serialize user, project, false
      serialized.should_not have_key :structures
    end

    it "serializes a project's subjects count" do
      serialized = subject.serialize user, project, false
      serialized[:subjectsCount].should == 4
    end

    it "serializes a project's forms count" do
      serialized = subject.serialize user, project, false
      serialized[:formsCount].should == 2
    end

    context "admin names" do
      let (:user1) { create :user, first_name: "Ima", last_name: "Admin", email: "one@user.com", password: "Complex1" }
      let (:user2) { create :user, first_name: "Soam", last_name: "Eye", email: "two@user.com", password: "Complex1" }
      let (:user3) { create :user, first_name: "Final", last_name: "Boss", email: "three@user.com", password: "Complex1" }
      let (:team_member1) { TeamMember.create user: user1, administrator: true }
      let (:team_member2) { TeamMember.create user: user2, administrator: true }
      let (:team_member3) { TeamMember.create user: user3 }

      it "serializes a project's administrators" do
        project.team_members = [team_member1, team_member2, team_member3]
        project.save!
        serialized = subject.serialize user, project, false
        serialized[:administratorNames].should be_in ["Ima Admin, Soam Eye", "Soam Eye, Ima Admin"]
      end
      it "doesn't blow up for null administrators" do
        team_member_empty = TeamMember.create project: project, administrator: true
        project.team_members = [team_member1, team_member_empty, team_member3]
        project.save!
        serialized = subject.serialize user, project, false
        serialized[:administratorNames].should == "Ima Admin"
      end
    end
  end
end
