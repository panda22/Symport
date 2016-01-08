describe FormStructurePermissionSerializer do
  subject { described_class }
  let (:user) { User.new first_name: "Abraham", last_name: "Lincoln", email: "blah@blah.com" }
  let (:team_member) { TeamMember.new user: user }
  let (:form_structure_id) { SecureRandom.uuid }
  let (:structure) { FormStructure.new id: form_structure_id, name: "Emancipation" }

  describe '.serialize' do
    it 'serializes permissions' do
      full = FormStructurePermission.new permission_level: "Full", team_member: team_member, form_structure: structure
      read_write = FormStructurePermission.new permission_level: "Read/Write", team_member: team_member, form_structure: structure
      subject.serialize(full)[:permissionLevel].should == "Full"
      subject.serialize(read_write)[:permissionLevel].should == "Read/Write"
    end

    it 'serializes id' do
      an_id = SecureRandom.uuid
      full = FormStructurePermission.new permission_level: "Full", id: an_id, team_member: team_member, form_structure: structure
      subject.serialize(full)[:id].should == an_id
    end

    it 'serializes form name' do
      full = FormStructurePermission.new permission_level: "Full", team_member: team_member, form_structure: structure
      subject.serialize(full)[:formStructureName].should == "Emancipation"
    end

    it 'serializes form id' do
      full = FormStructurePermission.new permission_level: "Full", team_member: team_member, form_structure: structure
      subject.serialize(full)[:formStructureID].should == form_structure_id
    end
  end
end
