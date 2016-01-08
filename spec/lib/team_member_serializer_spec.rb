describe TeamMemberSerializer do
  subject { described_class }
  before do
    mock_class FormStructurePermissionSerializer
    FormStructurePermissionSerializer.stubs(:serialize).returns({})
  end

  describe '.serialize' do
    let (:team_member_id) { SecureRandom.uuid }
    let (:user) { User.new first_name: "Samus", last_name: "Aran", email: "super@metroid.com" }
    let (:project) { Project.new name: "Primse" }
    let (:team_member) { TeamMember.new({
        id: team_member_id, 
        project: project,
        user: user, 
        expiration_date: Date.parse("August 13, 2015"),
        administrator: false,
        form_creation: true,
        audit: false,
        export: true,
        view_personally_identifiable_answers: true
      })
    }

    it 'serializes a team member id' do
      subject.serialize(user, team_member)[:id].should == team_member_id
    end

    it 'serializes a team member first name' do
      subject.serialize(user, team_member)[:firstName].should == "Samus"
    end

    it 'serializes a team member last name' do
      subject.serialize(user, team_member)[:lastName].should == "Aran"
    end

    it 'serializes a team member email' do
      subject.serialize(user, team_member)[:email].should == "super@metroid.com"
    end

    it 'serializes a team member expiration date' do
      subject.serialize(user, team_member)[:expirationDate].should == "8/13/2015"
    end

    it 'serializes a team member administrator flag' do
      subject.serialize(user, team_member)[:administrator].should be_false
    end

    it 'serializes a team member form creation flag' do
      subject.serialize(user, team_member)[:formCreation].should be_true
    end

    it 'serializes a team member audit log flag' do
      subject.serialize(user, team_member)[:auditLog].should be_false
    end

    it 'serializes a team member export flag' do
      subject.serialize(user, team_member)[:export].should be_true
    end

    it 'serializes a team member PHI flag' do
      subject.serialize(user, team_member)[:viewPersonallyIdentifiableAnswers].should be_true
    end

    it 'serializes non-administrator flags as true if administrator set' do
      team_member.export = false
      team_member.form_creation = false
      team_member.audit = false
      team_member.view_personally_identifiable_answers = false
      team_member.administrator = true
      subject.serialize(user, team_member)[:formCreation].should be_true
      subject.serialize(user, team_member)[:auditLog].should be_true
      subject.serialize(user, team_member)[:export].should be_true
      subject.serialize(user, team_member)[:viewPersonallyIdentifiableAnswers].should be_true
    end

    it "serializes form structure permissions" do
      struct1 = FormStructure.create! name: "Zebes"
      existing_perm = FormStructurePermission.create! team_member: team_member, permission_level: "Full"
      struct1.form_structure_permissions << existing_perm
      struct1.save!
      struct2 = FormStructure.create! name: "SR388"
      project.form_structures = [struct1, struct2]
      project.save!
      FormStructurePermissionSerializer.expects(:serialize).with(existing_perm).returns "serialized existing"
      FormStructurePermissionSerializer.expects(:serialize).with do |perm|
        perm.permission_level == "None" and perm.id.nil?
      end.returns "serialized new"
      subject.serialize(user, team_member)[:structurePermissions].should =~ ["serialized existing", "serialized new"]
    end

    it "serializes whether or not the current user is this team member" do
      subject.serialize(user, team_member)[:isCurrentUser].should be_true
      subject.serialize(User.new, team_member)[:isCurrentUser].should be_false
    end
  end
end
