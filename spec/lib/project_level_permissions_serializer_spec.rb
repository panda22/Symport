describe ProjectLevelPermissionsSerializer do
  subject { described_class }
  let (:user) { User.new }
  let (:project) { Project.new }

  describe '.serialize' do
    before do
      Permissions.stubs(:user_can_edit_project_settings?).returns false
      Permissions.stubs(:user_can_create_forms_in_project?).returns false
      Permissions.stubs(:user_can_rename_subject_ids_in_project?).returns false
    end
    it 'serializes permission for edit settings' do
      Permissions.expects(:user_can_edit_project_settings?).with(user,project).returns(true)
      subject.serialize(user, project)[:editSettings].should be_true
      Permissions.expects(:user_can_edit_project_settings?).with(user,project).returns(false)
      subject.serialize(user, project)[:editSettings].should be_false
    end

    it 'serializes permission for create form' do
      Permissions.expects(:user_can_create_forms_in_project?).with(user,project).returns(true)
      subject.serialize(user, project)[:createForms].should be_true
      Permissions.expects(:user_can_create_forms_in_project?).with(user,project).returns(false)
      subject.serialize(user, project)[:createForms].should be_false
    end

    it "includes whether the user has permission to manage subject IDs" do
      Permissions.expects(:user_can_rename_subject_ids_in_project?).returns true
      subject.serialize(user, project)[:renameSubjectIDs].should be_true
      Permissions.expects(:user_can_rename_subject_ids_in_project?).returns false
      subject.serialize(user, project)[:renameSubjectIDs].should be_false
    end
  end
end
