describe FormStructuresController do

  let(:project) { Project.create! id: SecureRandom.uuid, name: "Project" }
  let(:structure_record) { FormStructure.create! id: SecureRandom.uuid, name: "blaah", project: project, is_many_to_one: false }
  let(:updated_structure_record) { FormStructure.new id: SecureRandom.uuid, project: project }
  let(:serialized_structure) {{'name' => 'something'}}
  let(:data_params) {{'name' => 'whatever'}}

  before do
    sign_in
    @user = controller.current_user
    @user.id = SecureRandom.uuid
    User.create!(id: @user.id, email: "joe@shmo.com", first_name: "joe", last_name: "shmo", password: "Complex#2", password_confirmation: "Complex#2", phone_number: "1234567890")
    TeamMember.create!(user_id: @user.id, project_id: project.id, administrator: true)
    FormBuilderLookup.stubs(:find_structure).with(@user, structure_record.id).returns(structure_record)
  end

  describe "#response_query" do
    it 'shows the existing responses' do
      resp1 = FormResponse.new
      resp2 = FormResponse.new
      resp3 = FormResponse.new
      page_number = 1
      subject_id = 123
      current_page = 1
      total_pages = 4
      FormBuilderLookup.expects(:find_structure).with(@user, structure_record.id).returns(structure_record)
      get :response_query, id: structure_record.id, format: :json
      response.should be_success
      response.body.should == {
        grid: [], 
        gridHeader: [ 
          {value: "Subject ID", type: "text"},
          {value: "Total Filled %", type: "numericalrange"}
        ],
        subjectDates: {}
      }.to_json
    end
  end

  describe "#existing_subjects" do
    it "gets all existing subjects for the form" do
      resp1 = FormResponse.new(:subject_id => "1")
      resp2 = FormResponse.new(:subject_id => "1")
      resp3 = FormResponse.new(:subject_id => "2")
      new_form = FormStructure.new(:name => "abcde")
      new_form.form_responses << resp1
      new_form.form_responses << resp2
      new_form.form_responses << resp3
      new_form.save!
      get :existing_subjects, id: new_form.id
      response.should be_success
      response.body.should == {existing_ids: ["2", "1"]}.to_json
    end
  end

  describe "#set_response_secondary_ids" do
    let(:new_form) { FormStructure.new(:name => "abcde", :id => SecureRandom.uuid) }
    let(:resp1) { FormResponse.new(:subject_id => "1") }
    let(:secondary_id) { "abc" }

    before do
      new_form.form_responses << resp1
    end

    it "sets all response secondary ids in the form" do
      id = new_form.id
      FormStructure.expects(:find).with(id).returns(new_form)
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(@user, new_form).returns(true)
      FormStructureSerializer.expects(:serialize).with(@user, new_form, true).returns({name: 'something'})
      post :set_response_secondary_ids, id: id, secondary_id: secondary_id
      response.should be_success
      response.body.should == {formStructure: {name: 'something'}}.to_json
    end

    it "throws error if secondary_id is not set" do
      id = new_form.id
      post :set_response_secondary_ids, id: id, secondary_id: ""
      response.should_not be_success
      response.body.should == {validations: {name: "Please enter a name"}}.to_json
    end

    it "throws an error if user has insufficient permissions" do
      id = new_form.id
      FormStructure.expects(:find).with(id).returns(new_form)
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(@user, new_form).returns(false)
      post :set_response_secondary_ids, id: id, secondary_id: secondary_id
      response.should_not be_success
      response.body.should == {message: "You do not have access to edit responses for this form"}.to_json
    end
  end

  describe "#get_max_instances" do
    it "gets max instances for any subject for a form" do
      id = structure_record.id
      FormStructure.expects(:find).with(id).returns(structure_record)
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(@user, structure_record).returns(true)
      FormResponseLookup.expects(:get_max_instances_in_form).with(id).returns(3)
      get :get_max_instances, id: id
      response.should be_success
      response.body.should == {numInstances: 3}.to_json
    end

    it "throws an error if user has insufficient permissions" do
      id = structure_record.id
      FormStructure.expects(:find).with(id).returns(structure_record)
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(@user, structure_record).returns(false)
      get :get_max_instances, id: id
      response.should_not be_success
      response.body.should == {message: "You do not have access to edit responses for this form"}.to_json
    end
  end

  describe '#shows' do
    it 'serializes and shows a form structure' do
      FormStructureSerializer.expects(:serialize).with(@user, structure_record, true).returns(serialized_structure)
      get :show, id: structure_record.id, format: :json
      response.should be_success
      response.body.should == {formStructure: {name: 'something'}}.to_json
    end
  end

  describe '#update' do
    let(:data) {{ 'whatever' => 'whenever'}}
    it 'updates a form structure' do
      FormStructureUpdater.expects(:update).with(@user, structure_record, data).returns(updated_structure_record)
      FormStructureSerializer.expects(:serialize).with(@user, updated_structure_record, false).returns(serialized_structure)
      put :update, id: structure_record.id, form_structure: data, format: :json
      response.should be_success
      response.body.should == {formStructure: {name: 'something'}}.to_json
    end

    it "returns error information " do
      structure_record.errors[:name] << "not unique name!"
      exception = ActiveRecord::RecordInvalid.new structure_record

      FormStructureUpdater.expects(:update).with(@user, structure_record, data).raises exception

      put :update, id: structure_record.id, form_structure: data, format: :json
      response.code.should == "422"
      response.body.should == {
        validations: {
          name: ["not unique name!"]
        }
      }.to_json
    end
  end

  describe '#destroy' do
    it 'deletes a form structure' do
      ProjectSerializer.expects(:serialize).with(@user, project, true).returns({'a' => 'b'})
      FormStructureDestroyer.expects(:destroy).with(@user, structure_record).returns(nil)
      delete :destroy, id: structure_record.id, format: :json
      response.should be_success
      response.body.should == {"project" => { "a" => "b" }}.to_json
    end
  end

  #describe '#export' do
  #  it "exports a form's responses" do
  #    responses = [FormResponse.new, FormResponse.new]
  #    structure = FormStructure.new form_responses: responses
  #    FormBuilderLookup.expects(:find_structure).with(@user, "1234").returns structure
  #    generator = ExportTableGenerator.new "abc", []
  #    FormResponsesTableGeneratorBuilder.expects(:build).with(true, @user, structure).returns generator
  #    csv_data = "a,b,c\n1,2,3"
  #    ExportCsvGenerator.expects(:generate).with(generator, responses).returns csv_data
  #    AuditLogger.expects(:export).with(@user, structure, generator)
  #    post :export, id: "1234", includePhi: "true"
  #    response.should be_success
  #    response.body.should == csv_data
  #    response.content_type.should == "text/csv"
  #    response["Content-Disposition"].should =~ /attachment; filename=\"abc\.csv\"/
  #  end
  #end
end
