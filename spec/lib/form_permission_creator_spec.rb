describe FormPermissionCreator do
  subject { described_class }

  let(:project_1) { Project.create name: "Project 1" }
  let(:form_1) { FormStructure.create name: "Form 1", project: project_1 }
  let(:form_permission_data) { {"userEmail" => "john@smith.com", "permissionLevel" => "Read" } }
  let(:john_smith) { john_smith = create :user, email: "john@smith.com", password: "ZZabc123" }

  it "creates a new form permission on the form structure" do
    team_member_1 = TeamMember.create!(user: john_smith, administrator: false, project: project_1)

    form_permission = FormPermissionCreator.create(form_1, form_permission_data)
    form_permission.reload
    form_permission.form_structure.should == form_1
    form_permission.team_member.should == team_member_1
  end

  it "raises an error when team member has already a permission level for this form" do
    team_member_1 = TeamMember.create!(user: john_smith, administrator: false, project: project_1)
    FormStructurePermission.create!(team_member: team_member_1, form_structure: form_1, permission_level: "Read/Write")

    expect { FormPermissionCreator.create(form_1, form_permission_data) }.to raise_error { |err|
      err.error[:validations][:userEmail].should == "The team member john@smith.com has already a permission for this form"
    }
  end

end
