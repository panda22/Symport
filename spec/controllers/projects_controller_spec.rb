describe ProjectsController do
  before do
    mock_class ProjectLookup, strict: true
    mock_class ProjectCreator, strict: true
    mock_class ProjectSerializer, strict: true
    mock_class FormStructureCreator, strict: true
    sign_in
  end

  describe '#index' do
    it "returns a list of serialized projects for the user" do
      user = controller.current_user
      project1 = Project.new
      project2 = Project.new
      project3 = Project.new
      ProjectLookup.expects(:find_projects_for_user).with(user).returns [project1, project2, project3]
      ProjectSerializer.expects(:serialize).with(user, project1, false).returns "project1"
      ProjectSerializer.expects(:serialize).with(user, project2, false).returns "project2"
      ProjectSerializer.expects(:serialize).with(user, project3, false).returns "project3"
      get :index
      response.should be_success
      response.body.should == {projects: ["project1", "project2", "project3"]}.to_json
    end
  end

  describe '#create_structure' do
    it 'creates a new form structure for the project' do
      user = controller.current_user
      structure = FormStructure.new
      structure_data = {'a' => 'b'}
      structure_serialized = {'c' => 'd'}
      project = Project.new
      ProjectLookup.expects(:find_project).with(user, '123').returns project
      FormStructureCreator.expects(:create).with(structure_data, user, project).returns(structure)
      FormStructureSerializer.expects(:serialize).with(user, structure, true).returns(structure_serialized)
      post :create_structure, id: '123', form_structure: structure_data
      response.should be_success
      response.body.should == {'formStructure' => { 'c' => 'd'}}.to_json
    end

    it "returns error information when trying to create project with no name" do
      form_structure = FormStructure.new
      form_structure.errors[:name] << "need a name!"
      exception = ActiveRecord::RecordInvalid.new form_structure

      user = controller.current_user
      project = Project.new
      ProjectLookup.expects(:find_project).with(user, '123').returns project
      FormStructureCreator.expects(:create).raises exception

      post :create_structure, id: '123', form_structure: {}, format: :json
      response.code.should == "422"
      response.body.should == {
        validations: {
          name: ["need a name!"]
        }
      }.to_json
    end
  end

  describe '#create' do
    it 'creates a new project record' do
      user = controller.current_user
      project = Project.new
      ProjectCreator.expects(:create).with(user, {"name" => "Brand New Project"}).returns(project)
      ProjectSerializer.expects(:serialize).with(user, project, true).returns({a: 'b'})
      post :create, project: {name: "Brand New Project"}
      response.should be_success
      response.body.should == {project: { a: 'b'}}.to_json
    end

    it "returns error information" do
      user = controller.current_user
      project = Project.new
      project.errors[:name] << "need a name!"
      exception = ActiveRecord::RecordInvalid.new project

      ProjectCreator.expects(:create).with(user, {}).raises exception

      post :create, project: {}
      response.code.should == "422"
      response.body.should == {
        validations: {
          name: ["need a name!"]
        }
      }.to_json
    end
  end

  describe '#show' do
    it 'retrieves and serializes a project' do
      project = Project.new
      user = controller.current_user
      ProjectSerializer.expects(:serialize).with(user, project, true).returns({a: 'b'})
      ProjectLookup.expects(:find_project).with(user, '1234').returns(project)
      get :show, id: '1234'
      response.should be_success
      response.body.should == {project: {a: 'b'}}.to_json
    end
  end

  describe '#update' do
    it 'updates a project' do
      project = Project.new name: 'cherries'
      user = controller.current_user
      altered_project = Project.new name: 'apples'
      ProjectLookup.expects(:find_project).with(user, '1234').returns(project)
      ProjectUpdater.expects(:update).with({'name' => 'bananas'}, user, project).returns(altered_project)
      ProjectSerializer.expects(:serialize).with(user, altered_project, true).returns({a: 'b'})
      put :update, id: '1234', project: {name: 'bananas'}
      response.should be_success
      response.body.should == {project: {a: 'b'}}.to_json
    end
  end

  describe "#known_subjects" do
    it "fetches the known subjects" do
      project = mock "project"
      user = controller.current_user

      ProjectLookup.expects(:find_project).with(user, "a-cool-project").returns project
      SubjectLookup.expects(:known_subjects_of_project).with(project).returns "...a list of known subjects..."
      get :known_subjects, id: "a-cool-project"
      response.should be_success
      response.body.should == {subjects: "...a list of known subjects..."}.to_json
    end
  end

  describe "#rename_subject_id" do
    it "renames the subject ID" do
      project = mock "project"
      user = controller.current_user

      ProjectLookup.expects(:find_project).with(user, "some-project-id").returns project
      ProjectUpdater.expects(:rename_subject_id).with(user, project, "an-old-id", "awesome-new-id")

      put :rename_subject_id, id: "some-project-id", oldSubjectID: "an-old-id", newSubjectID: "awesome-new-id"
      response.should be_success
    end
  end

  describe '#destroy' do
    it 'destroys a project' do
      project_id = SecureRandom.uuid
      project = Project.create id: project_id, name: "Project1"
      user = controller.current_user

      ProjectLookup.expects(:find_project).with(user, project_id).returns(project)
      ProjectDestroyer.expects(:destroy).with(user, project)
      delete :destroy, id: project.id
      response.should be_success
    end
  end
end
