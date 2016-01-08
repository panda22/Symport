describe FormQuestionsController do

  subject { FormQuestionsController.new }

  let(:question) { FormQuestion.new id: 1 }
  let(:structure) { FormStructure.new id: 2 }
  let(:updated_structure) { FormStructure.new id: 3 }
  let(:serialized_structure) { {'name' => 'Structure1' } }
  let(:data) { { 'prompt' => "apples", "description" => "bananas" } }
  let(:error) { { 'errors' => ['uhoh'] } }

  before do
    sign_in
    @user = controller.current_user
    FormBuilderLookup.stubs(:find_question).with(@user, '1').returns(question)
    FormBuilderLookup.stubs(:find_structure).with(@user, '2').returns(structure)
    mock_class FormStructureSerializer, strict: true
  end

  describe "#update" do
    it "updates a question and redirects to form structure" do
      FormQuestionUpdater.expects(:update).with(@user, question, structure, data, nil).returns updated_structure
      FormStructureSerializer.expects(:serialize).with(@user, updated_structure, true).returns serialized_structure
      post :update, id: 1, form_structure_id: 2, form_question: data, format: :json
      response.should be_success
      response.body.should ==  {formStructure: {'name' => 'Structure1'}}.to_json
    end
    it "returns error info when update fails" do
      FormQuestionUpdater.expects(:update).with(@user, question, structure, data, nil).raises(PayloadException.new(422, error))
      FormStructureSerializer.expects(:serialize).never
      post :update, id: 1, form_structure_id: 2, form_question: data, format: :json
      response.should_not be_success
      response.body.should == {errors: ['uhoh']}.to_json
    end
  end

  describe "#create" do
    it "creates a question and redirects to form structure" do
      FormQuestionCreator.expects(:create).with(@user, structure, data, nil).returns updated_structure
      FormStructureSerializer.expects(:serialize).with(@user, updated_structure, true).returns serialized_structure
      post :create, form_structure_id: 2, form_question: data, format: :json
      response.should be_success
      response.body.should == {formStructure: {'name' => 'Structure1'}}.to_json
    end
    it "returns error info when update fails" do
      FormQuestionCreator.expects(:create).with(@user, structure, data, nil).raises(PayloadException.new(422, error))
      FormStructureSerializer.expects(:serialize).never
      post :create, form_structure_id: 2, form_question: data, format: :json
      response.should_not be_success
      response.body.should == {errors: ['uhoh']}.to_json
    end

    it "returns validation errors" do
      form_question = FormQuestion.new question_type: 'numericalrange'
      form_question.numerical_range_config = NumericalRangeConfig.new
      form_question.errors[:prompt] << "can't be empty!"
      form_question.numerical_range_config.errors[:minimum_value] << "can't be empty!"
      exception = ActiveRecord::RecordInvalid.new form_question

      FormQuestionCreator.expects(:create).raises exception
      FormQuestionSerializer.expects(:validation_errors).with(exception.record).returns("serialized validation errors")
      post :create, form_structure_id: 2, form_question: data, format: :json

      response.code.should == "422"
      response.body.should == { validations: 'serialized validation errors'}.to_json

    end
  end

  describe "#destroy" do
    it "destroys a question" do
      FormQuestionDestroyer.expects(:destroy).with(@user, question, structure).returns updated_structure
      FormStructureSerializer.expects(:serialize).with(@user, updated_structure, true).returns serialized_structure
      delete :destroy, id: 1, form_structure_id: 2, format: :json
      response.should be_success
    end
  end
end
