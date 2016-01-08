describe ProjectUpdater do
  subject { described_class }

  before do
    Permissions.stubs(:user_can_edit_project_settings?).returns true
    AuditLogger.stubs(:surround_edit).yields
  end

  let(:current_user) { User.new }

  describe '.update' do
    it 'updates the project name' do
      project = Project.create name: "The TTP Project"
      subject.update({'name' => 'Orthographic' }, current_user, project).should == project
      project.reload.name.should == 'Orthographic'
    end

    it 'removes leading and trailing spaces before updating' do
      project = Project.create name: "The TTP Project"
      subject.update({'name' => '     Orthographic     ' }, current_user, project).should == project
      project.reload.name.should == 'Orthographic'
    end

    it 'throws an error when unable to update' do
      conflicting_project = Project.create name: "I'm still here"
      project = Project.create name: "The TTP Project"
      expect {
        subject.update({'name' => nil }, current_user, project)
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'rejects updating if permissions are not there' do
      project = Project.create name: "The TTP Project"
      Permissions.expects(:user_can_edit_project_settings?).with(current_user, project).returns false
      expect {
        subject.update({'name' => "I'm still here" }, current_user, project)
      }.to raise_error PayloadException
    end

    it 'logs the editing event for a project' do
      project = Project.create! name: "Cool Project"
      AuditLogger.expects(:surround_edit).with(current_user, project).yields
      subject.update({'name' => 'Orthographic' }, current_user, project)
    end
  end

  describe ".rename_subject_id" do
    before do
      Permissions.stubs(:user_can_rename_subject_ids_in_project?).returns true
      SubjectLookup.stubs(:project_contains_subject_id?).returns false
      AuditLogger.stubs(:record_entry)
      @project = Project.create! name: "Gorilla Manor"
    end

    it "verifies that the user has permissions" do
      Permissions.expects(:user_can_rename_subject_ids_in_project?).with(current_user, @project).returns false

      exception = begin
        subject.rename_subject_id current_user, @project, "old", "new"
      rescue PayloadException => e
        e
      end

      exception.should be_a PayloadException
      exception.status.should == 403
    end

    it "rejects the change if the subject ID is already in use" do
      SubjectLookup.expects(:project_contains_subject_id?).with(@project, "cool new id").returns true

      exception = begin
        subject.rename_subject_id current_user, @project, "meh", "cool new id"
      rescue PayloadException => e
        e
      end

      exception.should be_a PayloadException
      exception.status.should == 422
      exception.error[:validations][:subject_id].should == "This subject ID is already in use"
    end

    it "renames the subject IDs actually" do
      form_a = create :empty_form_structure, project: @project, name: "Form A"
      form_b = create :empty_form_structure, project: @project, name: "Form B"

      resp1 = create :form_response, form_structure: form_a, subject_id: "Sticky Thread"
      resp2 = create :form_response, form_structure: form_b, subject_id: "Sticky Thread"
      resp3 = create :form_response, form_structure: form_a, subject_id: "Cubism Dream"
      resp4 = create :form_response, form_structure: form_b, subject_id: "World News"

      subject.rename_subject_id current_user, @project, "Sticky Thread", "Cards & Quarters"

      resp1.reload.subject_id.should == "Cards & Quarters"
      resp2.reload.subject_id.should == "Cards & Quarters"
      resp3.reload.subject_id.should == "Cubism Dream"
      resp4.reload.subject_id.should == "World News"
    end

    it "logs the change in the audit log" do
      AuditLogger.expects(:record_entry).with(current_user, @project, "edit", {
        old_data: {subject_id: "Sun Hands"},
        data: {subject_id: "Cubism Dream"}
      })

      subject.rename_subject_id current_user, @project, "Sun Hands", "Cubism Dream"
    end
  end
end
