describe TeamRecordCreator do
  subject { described_class }

  describe '.create_team_member' do
    it 'creates a team member' do
      project = Project.create!(name: 'Project_A')
      user = create :user, email: 'user_a@blah.com', password: "Complex1"
      expiration_date = Date.tomorrow
      team_member_data = {
        project: project,
        user: user,
        expiration_date: expiration_date,
        administrator: false,
        form_creation: true,
        audit:  true,
        export: true,
        view_personally_identifiable_answers: true
      }

      record = subject.create_team_member(team_member_data)
      record.project.should == project
      record.user.should == user
      record.expiration_date.should == expiration_date
      record.administrator.should be_false
      record.form_creation.should be_true
      record.audit.should be_true
      record.export.should be_true
      record.view_personally_identifiable_answers.should be_true
    end
  end

  describe '.create_form_structure_permission' do
    it "creates a form structure permission" do
      project = Project.create!(name: 'Project_A')
      user = create :user, email: 'user_a@blah.com', password: "Complex1"
      team_member = TeamMember.create!(project: project, user: user,
                     expiration_date: Date.tomorrow,
                     administrator: false,
                     form_creation: true,
                     audit: true,
                     export: true,
                     view_personally_identifiable_answers: true)

      form_structure = FormStructure.create!(name: 'Form_A')

      data = {team_member: team_member, form_structure: form_structure, permission_level: "Read"}

      record = TeamRecordCreator.create_form_structure_permission(data)

      record.team_member.should == team_member
      record.permission_level.should == "Read"
      record.form_structure.should == form_structure
    end
  end
end