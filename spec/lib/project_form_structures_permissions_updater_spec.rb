describe ProjectFormStructuresPermissionsUpdater do
  subject { described_class }
  describe '.update' do
    before do
      AuditLogger.stubs(:surround_edit).yields
    end
    let(:current_user) { User.new }
    let(:structure_1_id) { SecureRandom.uuid }
    let(:structure_2_id) { SecureRandom.uuid }
    let(:structure_3_id) { SecureRandom.uuid }
    let(:structure_1) { FormStructure.create id: structure_1_id, name: "Dracula's Castle" }
    let(:structure_2) { FormStructure.create id: structure_2_id, name: "Upside-down Castle" }
    let(:structure_3) { FormStructure.create id: structure_3_id, name: "Sideways Castle" }
    let(:project) { Project.create name: "Symphony of the Night", form_structures: [structure_1, structure_2] }
    let(:user) { create :user, email: "alucard@dhampir.com", password: "Complex1" }
    let(:perm_1) { FormStructurePermission.create form_structure: structure_1, permission_level: "Read" }
    let(:perm_3) { FormStructurePermission.create form_structure: structure_2, permission_level: "Full" }
    let(:team_member) { TeamMember.create user: user, project: project, form_structure_permissions: [perm_1, perm_3] }
    let(:data) { [
      {"formStructureID" => structure_1_id, "permissionLevel" => "Full"},
      {"formStructureID" => structure_2_id, "permissionLevel" => "Read/Write"}
    ] }

    it "assigns permission level based on client data" do
      subject.update(current_user, team_member, data)
      team_member.reload.form_structure_permissions.find_by(form_structure: structure_1).permission_level.should == "Full"
    end

    it "deletes out-dated permissions" do
      subject.update(current_user, team_member, data)
      team_member.reload.form_structure_permissions.find_by(form_structure: structure_3).should be_nil
    end

    it "creates new 'None' permissions where client data did not contain element" do
      subject.update(current_user, team_member, data)
      team_member.reload.form_structure_permissions.find_by(form_structure: structure_2).permission_level.should == "Read/Write"
    end

    it "logs editing of form permissions" do
      AuditLogger.expects(:surround_edit).with(current_user, perm_1).yields
      AuditLogger.expects(:surround_edit).with(current_user, perm_3).yields
      subject.update(current_user, team_member, data)
    end
  end
end
