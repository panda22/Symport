describe FormResponsesController do
  subject { described_class }
  let(:id) { SecureRandom.uuid }
  let(:response_record) { FormResponse.new id: id }
  let(:serialize_response) { {id: id, date: 'today'}}

  before do
    mock_class FormResponseSerializer, strict: true
    mock_class FormResponseLookup, strict: true
    sign_in
    @user = controller.current_user
  end

  describe '#show' do
    before do
      AuditLogger.stubs(:view)
    end
    let (:subject_id) { "abc123" }
    let (:resp1) { FormResponse.new subject_id: subject_id }

    it "finds the response for existing subject" do
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, id, subject_id, 0).returns(resp1)
      FormResponseSerializer.expects(:serialize).with(@user, resp1, true).returns("Serialized Form Response")
      get :show, form_structure_id: id, id: subject_id, format: :json
      response.should be_success
      response.body.should == { formResponse: "Serialized Form Response" }.to_json
    end

    it "creates an empty response when no subject exists" do
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, id, subject_id, 0).returns(nil)
      structure = FormStructure.new
      FormBuilderLookup.expects(:find_structure).with(@user, id).returns(structure)
      FormResponseBuilder.expects(:build).with(@user, structure, subject_id).returns(resp1)
      AuditLogger.expects(:view).never
      FormResponseSerializer.expects(:serialize).with(@user, resp1, true).returns("Serialized Form Response")
      get :show, form_structure_id: id, id: subject_id, format: :json
      response.should be_success
      response.body.should == { formResponse: "Serialized Form Response" }.to_json      
    end

    it "logs views" do
      resp1 = FormResponse.new subject_id: subject_id
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, id, subject_id, 0).returns(resp1)
      FormResponseSerializer.expects(:serialize).with(@user, resp1, true).returns("Serialized Form Response")
      AuditLogger.expects(:view).with(@user, resp1)
      get :show, form_structure_id: id, id: subject_id, format: :json
      response.should be_success
    end
  end

  describe "#get_by_subject_and_instance" do
    before do
      AuditLogger.stubs(:view)
    end
    let (:subject_id) { "abc123" }
    let (:resp1) { FormResponse.new subject_id: subject_id, instance_number: 0 }
    let (:resp2) { FormResponse.new subject_id: subject_id, instance_number: 1 }

    it "finds the response for existing subject and instance" do
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, id, subject_id, 0).returns(resp1)
      FormResponseSerializer.expects(:serialize).with(@user, resp1, true).returns("Serialized Form Response")
      get :get_by_subject_and_instance, form_structure_id: id, subject_id: subject_id, instance_number: 0, format: :json
      response.should be_success
      response.body.should == { formResponse: "Serialized Form Response" }.to_json
    end

    it "creates an empty response when subject exists with different instance_number" do
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, id, subject_id, 1).returns(nil)
      structure = FormStructure.new
      FormBuilderLookup.expects(:find_structure).with(@user, id).returns(structure)
      FormResponseBuilder.expects(:build).with(@user, structure, subject_id).returns(resp1)
      AuditLogger.expects(:view).never
      FormResponseSerializer.expects(:serialize).with(@user, resp1, true).returns("Serialized Form Response")
      get :get_by_subject_and_instance, form_structure_id: id, subject_id: subject_id, instance_number: 1, format: :json
      response.should be_success
      response.body.should == { formResponse: "Serialized Form Response" }.to_json
    end
  end

  describe '#update' do
    let(:data) {{ 'user' => 'bob' }}
    let(:resp) { FormResponse.create subject_id: 'abc', instance_number: 0 }
    let(:question1) { FormQuestion.create! sequence_number: 100, display_number: "100", question_type: 'email' }
    let(:answer1) { FormAnswer.create(form_response: resp, form_question: question1, answer: 'sweet answer') }
    let(:form_structure_id) { SecureRandom.uuid }
    let(:resp2) { FormResponse.create! subject_id: 'abc', instance_number: 1 }
    let(:answer2) { FormAnswer.create(form_response: resp2, form_question: question1, answer: 'sour answer') }

    it "updates a form response" do
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, form_structure_id, "abc", 0).returns(resp)
      updated_resp = FormResponse.new
      FormResponseUpdater.expects(:update).with(@user, resp, data).returns updated_resp
      FormResponseSerializer.expects(:serialize).with(@user, updated_resp).returns("serialized_response")
      put :update, form_structure_id: form_structure_id, id: "abc", form_response: data, format: :json
      response.should be_success
      response.body.should ==  {formResponse: "serialized_response"}.to_json
    end

    it "updates a form response with a different instance_number" do
      new_data = data.dup
      new_data["instanceNumber"] = 1
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, form_structure_id, "abc", 1).returns(resp2)
      updated_resp = FormResponse.new
      FormResponseUpdater.expects(:update).with(@user, resp2, new_data).returns updated_resp
      FormResponseSerializer.expects(:serialize).with(@user, updated_resp).returns("serialized_response")
      put :update, form_structure_id: form_structure_id, id: "abc", form_response: new_data, format: :json
      response.should be_success
      response.body.should ==  {formResponse: "serialized_response"}.to_json
    end

    it "returns error info when update fails" do
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, form_structure_id, "abc", 0).returns(resp)
      FormResponseUpdater.expects(:update).with(@user, resp, data).raises(PayloadException.new(422, err: 'nope'))
      put :update, form_structure_id: form_structure_id, id:"abc", form_response: data, format: :json
      response.should_not be_success
      response.body.should == {err: 'nope'}.to_json
    end
    
    it "creates a response record when none exists" do
      FormResponseLookup.expects(:find_response_by_subject_id).with(@user, form_structure_id, "abc", 0).returns(nil)
      updated_resp = FormResponse.new

      structure = FormStructure.new
      FormBuilderLookup.expects(:find_structure).with(@user, form_structure_id).returns(structure)
      FormRecordCreator.expects(:create_response).with("abc", structure, [], 0, nil).returns(resp)
      AuditLogger.expects(:add).with(@user, resp)
      FormResponseUpdater.expects(:update).with(@user, resp, data).returns updated_resp
      FormResponseSerializer.expects(:serialize).with(@user, updated_resp).returns("serialized_response")
      put :update, form_structure_id: form_structure_id, id: "abc", form_response: data, format: :json
      response.should be_success
      response.body.should ==  {formResponse: "serialized_response"}.to_json        
    end
  end

  describe '#destroy' do
    it 'destroys a form response' do
      #FormResponseLookup.expects(:find_response_by_subject_id).with(@user, "struct_id", id, 0).returns(response_record)
      FormResponse.expects(:find_by).with(:id => id).returns(response_record)
      FormResponseDestroyer.expects(:destroy).with(@user, response_record).returns(nil)
      delete :destroy, form_structure_id: "struct_id", id: id, format: :json
    end
  end

  describe "#rename_instance" do
    let(:structure) {FormStructure.create! name: "blaaah", is_secondary_id_sorted: true, is_many_to_one: true, secondary_id: "first"}
    let(:resp) { FormResponse.create! subject_id: 'abc', secondary_id: 'yay', form_structure_id: structure.id}
    it "changes the secondary id of a response" do
      new_secondary_id = "boo"
      FormResponseLookup.expects(:find_response).with(@user, resp.id).returns(resp)
      FormResponseOrderer.expects(:order).with(resp).returns(resp)
      FormResponseSerializer.expects(:serialize).with(@user, resp).returns("serialized_response")
      post :rename_instance, id: resp.id, secondary_id: new_secondary_id
      response.should be_success
      response.body.should ==  {formResponse: "serialized_response"}.to_json
    end
  end

  describe "#destroy_instances_for_subject" do
    let(:form_structure_id) { SecureRandom.uuid }
    let(:subject_id) { "abcd" }
    it "destroys all instances for a subject" do
      project = Project.new
      structure = FormStructure.new(:id => form_structure_id)
      structure.project = project
      resp = FormResponse.new
      FormStructure.expects(:find).with(form_structure_id).returns(structure)
      FormResponse.expects(:where).with(:form_structure_id => [], :subject_id => subject_id).returns([resp])
      FormResponseDestroyer.expects(:destroy).with(@user, resp).returns(1)
      get :destroy_instances_for_subject, form_id: form_structure_id, subject_id: subject_id
      response.should be_success
      response.body.should == {result: "success"}.to_json
    end
  end
end

























