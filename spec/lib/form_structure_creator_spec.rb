describe FormStructureCreator do
  subject { described_class }

  before do
    mock_class Permissions
    mock_class FormRecordCreator
    mock_class AuditLogger
    Permissions.stubs(:user_can_create_forms_in_project?).returns true
  end

  describe '.create' do
    let (:user) { User.new }
    let (:data) { {name: "My Cool Form"} }
    let (:uuid) { SecureRandom.uuid }
    let (:output_data) { {id: uuid, name: "My Saved Cool Form"} }
    let (:new_form_structure) { FormStructure.new id: uuid }
    let (:project) { Project.new }

    it 'creates a new form structure with the given name' do
      FormRecordCreator.expects(:create_structure).with(project, data).returns(new_form_structure)
      subject.create(data, user, project).should == new_form_structure
    end

    it 'returns an error payload when record could not be created' do
      FormRecordCreator.expects(:create_structure).with(project, data).raises(StandardError,"not gonna do it")
      expect { subject.create(data, user, project) }.to raise_error("not gonna do it")
    end

    it 'rejects user when they do not have appropriate permissions' do
      Permissions.expects(:user_can_create_forms_in_project?).with(user, project).returns(false)
      expect { subject.create(data, user, project) }.to raise_error PayloadException
    end

    it 'logs creation of a form structure' do
      FormRecordCreator.expects(:create_structure).with(project, data).returns(new_form_structure)
      AuditLogger.expects(:add).with(user, new_form_structure)
      subject.create(data, user, project)
    end
  end
end
