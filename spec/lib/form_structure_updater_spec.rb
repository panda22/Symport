describe FormStructureUpdater do
  subject { described_class }

  let (:user) { User.new }

  describe ".update" do
    before do
      AuditLogger.stubs(:surround_edit).yields
    end

    it "updates the name on the form structure" do
      structure_id = SecureRandom.uuid
      structure = FormStructure.create id: structure_id, name: "Fancy stuff"
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      subject.update(user, structure, name: "Taco Thursday").reload.name.should == "Taco Thursday"

      FormStructure.find(structure_id).name.should == "Taco Thursday"
    end

    it "removes leading and trailing spaces from form's name before updating" do
      structure_id = SecureRandom.uuid
      structure = FormStructure.create id: structure_id, name: "Fancy stuff"
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      subject.update(user, structure, name: "     Taco Thursday     ").reload.name.should == "Taco Thursday"
    end

    it "raises an error when it cannot save" do
      existing_structure = FormStructure.create name: "Fantastic Form"
      new_structure = FormStructure.create name: "Fantastic Three"
      Permissions.expects(:user_can_edit_form_structure?).with(user, new_structure).returns(true)

      expect {
        subject.update user, new_structure, name: "Fantastic Form"
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "raises an error when user lacks access" do
      structure_id = SecureRandom.uuid
      structure = FormStructure.create id: structure_id, name: "Fancy stuff"
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(false)
      expect {
        subject.update user, structure, name: "Fantastic Form"
      }.to raise_error PayloadException
    end

    it 'logs the editing event for a form structure' do
      structure_id = SecureRandom.uuid
      structure = FormStructure.create id: structure_id, name: "Fancy stuff"

      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      AuditLogger.expects(:surround_edit).with(user, structure).yields
      subject.update(user, structure, name: "Taco Thursday")
    end

    it "raises an error when there is a secondary id collision" do
      project = Project.create!(id: SecureRandom.uuid, name: "project abcd")
      form1 = FormStructure.create!(id: SecureRandom.uuid, project: project, is_many_to_one: true, secondary_id: "a", name: "123")
      form2 = FormStructure.create!(project: project, is_many_to_one: true, secondary_id: "b", name: "234")
      Permissions.expects(:user_can_edit_form_structure?).with(user, form2).returns(true)
      AuditLogger.expects(:surround_edit).with(user, form2).yields
      expect {
        subject.update(user, form2, {secondaryId: "a", name: "234", isManyToOne: true})
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "raises an error if form is changed to many to one but saves structure" do
      project = Project.create!(id: SecureRandom.uuid, name: "project abcd")
      form = FormStructure.create!(id: SecureRandom.uuid, project: project, is_many_to_one: false, name: "123")
      resp = FormResponse.create!(form_structure: form, subject_id: "subject 1")
      Permissions.expects(:user_can_edit_form_structure?).with(user, form).returns(true)
      AuditLogger.expects(:surround_edit).with(user, form).yields
      expect {
        subject.update(user, form, {secondaryId: "a", name: "234", isManyToOne: true})
      }.to raise_error PayloadException
      new_form = FormStructure.find(form.id)
      new_form.is_many_to_one.should == true
    end

    it "raises an error if form is changed to many to one if max_instances > 1" do
      project = Project.create!(id: SecureRandom.uuid, name: "project abcd")
      form = FormStructure.create!(secondary_id: "sid", project: project, is_many_to_one: true, name: "123")
      resp1 = FormResponse.create!(form_structure: form, subject_id: "subject 1", instance_number: 0, secondary_id: "a")
      resp2 = FormResponse.create!(form_structure: form, subject_id: "subject 1", instance_number: 1, secondary_id: "b")
      expect {
        subject.update(user, form, {secondaryId: "a", name: "234", isManyToOne: false})
      }.to raise_error PayloadException
      new_form = FormStructure.find(form.id)
      new_form.is_many_to_one.should == true
    end

    it "changes response secondary ids to nil if form is changed to one to one" do
      project = Project.create!(id: SecureRandom.uuid, name: "project abcd")
      form = FormStructure.create!(secondary_id: "sid", project: project, is_many_to_one: true, name: "123")
      resp = FormResponse.create!(form_structure: form, subject_id: "subject 1", instance_number: 0, secondary_id: "a")
      Permissions.expects(:user_can_edit_form_structure?).with(user, form).returns(true)
      AuditLogger.expects(:surround_edit).with(user, form).yields
      subject.update(user, form, {secondaryId: "a", name: "234", isManyToOne: false})
      FormResponse.find(resp.id).secondary_id.should == nil
    end
  end

end
