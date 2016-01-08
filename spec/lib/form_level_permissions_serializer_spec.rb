describe FormLevelPermissionsSerializer do
  subject { described_class }
  describe ".serialize" do
    before do
      Permissions.stubs(:user_can_view_form_responses_for_form_structure?).returns false
      Permissions.stubs(:user_can_delete_form_structure?).returns false
      Permissions.stubs(:user_can_create_forms_in_project?).returns false
      Permissions.stubs(:user_can_export_responses_for_project?).returns false
      Permissions.stubs(:user_can_edit_form_structure?).returns false
      Permissions.stubs(:user_can_enter_form_structure?).returns false
    end

    let(:user) { User.new }
    let(:project) { Project.new }
    let(:structure) { FormStructure.new project: project }

    it "serializes view data permissions" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, structure).returns false
      subject.serialize(user, structure)[:viewData].should be_false
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, structure).returns true
      subject.serialize(user, structure)[:viewData].should be_true
    end

    it "serializes enter data permissions" do
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, structure).returns false
      subject.serialize(user, structure)[:enterData].should be_false
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, structure).returns true
      subject.serialize(user, structure)[:enterData].should be_true
    end

    it "serializes delete form permissions" do
      Permissions.expects(:user_can_delete_form_structure?).with(user, structure).returns false
      subject.serialize(user, structure)[:deleteForm].should be_false
      Permissions.expects(:user_can_delete_form_structure?).with(user, structure).returns true
      subject.serialize(user, structure)[:deleteForm].should be_true
    end

    it "serializes rename form permissions" do
      Permissions.expects(:user_can_create_forms_in_project?).with(user, project).returns false
      subject.serialize(user, structure)[:renameForm].should be_false
      Permissions.expects(:user_can_create_forms_in_project?).with(user, project).returns true
      subject.serialize(user, structure)[:renameForm].should be_true
    end

    it "serializes download form data permissions" do
      Permissions.expects(:user_can_export_responses_for_project?).with(user, project).returns false
      subject.serialize(user, structure)[:downloadFormData].should be_false
      Permissions.expects(:user_can_export_responses_for_project?).with(user, project).returns true
      subject.serialize(user, structure)[:downloadFormData].should be_true
    end

    it "serializes build form permissions" do
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns false
      subject.serialize(user, structure)[:buildForm].should be_false
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns true
      subject.serialize(user, structure)[:buildForm].should be_true
    end

    it "serializes phi permissions" do
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns false
      subject.serialize(user, structure)[:viewPhiData].should be_false
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns true
      subject.serialize(user, structure)[:viewPhiData].should be_true
    end
  end
end
