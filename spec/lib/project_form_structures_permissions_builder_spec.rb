describe ProjectFormStructuresPermissionsBuilder do
  subject { described_class }
  describe '.build' do
    before do
      mock_class AuditLogger
    end
    let(:current_user) { User.new }
    let(:structure_1_id) { SecureRandom.uuid }
    let(:structure_2_id) { SecureRandom.uuid }
    let(:structure_1) { FormStructure.create id: structure_1_id, name: "Dracula's Castle" }
    let(:structure_2) { FormStructure.create id: structure_2_id, name: "Upside-down Castle" }
    let(:project) { Project.create name: "Symphony of the Night", form_structures: [structure_1, structure_2] }
    let(:data) { [
      {"formStructureID" => structure_1_id, "permissionLevel" => "Full"},
      {"formStructureID" => structure_2_id, "permissionLevel" => "Read/Write"}
    ] }

    it 'creates permissions based on items in the data sent from the client' do
      team_member = TeamMember.new
      perms_data_1 = {team_member: team_member, permission_level: 'Full', form_structure: structure_1}
      perms_data_2 = {team_member: team_member, permission_level: 'Read/Write', form_structure: structure_2}

      TeamRecordCreator.expects(:create_form_structure_permission).with(perms_data_1)
      TeamRecordCreator.expects(:create_form_structure_permission).with(perms_data_2)

      subject.build(current_user, project, team_member, data)
    end

    it 'creates "None" permissions for form structures not included in the data' do
      team_member = TeamMember.new
      perms_data_1 = {team_member: team_member, permission_level: 'Full', form_structure: structure_1}
      perms_data_2 = {team_member: team_member, permission_level: 'None', form_structure: structure_2}

      TeamRecordCreator.expects(:create_form_structure_permission).with(perms_data_1)
      TeamRecordCreator.expects(:create_form_structure_permission).with(perms_data_2)

      data.pop
      subject.build(current_user, project, team_member, data)
    end

    it "logs creation of form structure permissions" do
      team_member = TeamMember.new
      permission1 = FormStructurePermission.new
      permission2 = FormStructurePermission.new
      perms_data_1 = {team_member: team_member, permission_level: 'Full', form_structure: structure_1}
      perms_data_2 = {team_member: team_member, permission_level: 'Read/Write', form_structure: structure_2}

      TeamRecordCreator.expects(:create_form_structure_permission).with(perms_data_1).returns(permission1)
      TeamRecordCreator.expects(:create_form_structure_permission).with(perms_data_2).returns(permission2)


      AuditLogger.expects(:add).with(current_user, permission1)
      AuditLogger.expects(:add).with(current_user, permission2)

      subject.build(current_user, project, team_member, data).should =~ [permission1, permission2]
    end
  end
end
