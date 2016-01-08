describe FormDataController do
  subject { FormDataController.new }

  let(:project) { Project.new }
  let(:form_id) {SecureRandom.uuid}
  let(:form) { FormStructure.new(id: form_id, project: project) }
  let(:resp) { FormResponse.new(form_structure_id: form_id) }
  let(:rs) { {a: 1} }
  let(:questions) { [FormQuestion.new(form_structure: form)] }
  let(:obj1) { {I_am: "an_obj"} }
  let(:header_obj) { [{left: "yay"}, {right: "boo"}] }
  let(:body_obj) { {final: "object!"} }
  let(:error_obj) { ["hi"] }

  before do
    sign_in
    @user = controller.current_user
    FormStructure.stubs(:find).with(form_id).returns(form)
  end

  describe "get_initial_form_data" do
    it "gets form_data for form" do
      Permissions.expects(:user_can_see_form_structure?).with(@user, form).returns(true)
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(@user, form).returns(true)
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(@user, project).returns(true)
      FormDataLookup.expects(:get_other_questions_rs).with(form_id).returns(rs)
      FormDataGridConstructor.expects(:construct_other_question_hash).with(rs).returns(obj1)
      FormDataLookup.expects(:get_form_questions).with(form_id, true).returns(questions)
      FormDataLookup.expects(:get_responses_rs).with(form_id, true, true, 250).returns(rs)
      FormDataGridConstructor.expects(:construct_header).with(form, questions, obj1).returns(header_obj)
      FormDataGridConstructor.expects(:construct_body).with(form, rs, obj1).returns(body_obj)
      FormDataLookup.expects(:get_answer_error_by_question).with(form_id, true).returns(rs)
      FormDataErrorConstructor.expects(:construct_from_questions).with(rs).returns(error_obj)
      get :get_initial_form_data, form_id: form_id
      response.should be_success
      test_obj = {
          header: {
              left: header_obj[0],
              right: header_obj[1]
          },
          body: body_obj,
          initialSize: 250,
          isCompleted: true,
          formID: form_id,
          errors: error_obj,
          numErrors: 1,
          canView: true
      }
      response.body.should == test_obj.to_json
    end

    it "returns an empty grid if user does not have permission to view form" do
      Permissions.expects(:user_can_see_form_structure?).with(@user, form).returns(false)
      get :get_initial_form_data, form_id: form_id
      response.should be_success
      test_obj = {
          header: {
              left: [],
              right: []
          },
          body: [],
          initialSize: 250,
          isCompleted: true,
          formID: form_id,
          errors: {},
          numErrors: 0,
          canView: false
      }
      response.body.should == test_obj.to_json
    end

    it "returns an empty grid if user does not have permission to form responses" do
      Permissions.expects(:user_can_see_form_structure?).with(@user, form).returns(true)
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(@user, form).returns(false)
      get :get_initial_form_data, form_id: form_id
      response.should be_success
      test_obj = {
          header: {
              left: [],
              right: []
          },
          body: [],
          initialSize: 250,
          isCompleted: true,
          formID: form_id,
          errors: {},
          numErrors: 0,
          canView: false
      }
      response.body.should == test_obj.to_json
    end
  end

  describe "get_remaining_form_data" do
    it "gets form_data for form" do
      Permissions.expects(:user_can_see_form_structure?).with(@user, form).returns(true)
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(@user, form).returns(true)
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(@user, project).returns(true)
      FormDataLookup.expects(:get_other_questions_rs).with(form_id).returns(rs)
      FormDataGridConstructor.expects(:construct_other_question_hash).with(rs).returns(obj1)
      FormDataLookup.expects(:get_form_questions).with(form_id, true).returns(questions)
      FormDataLookup.expects(:get_responses_rs).with(form_id, true, false, 250).returns(rs)
      FormDataGridConstructor.expects(:construct_header).with(form, questions, obj1).returns(header_obj)
      FormDataGridConstructor.expects(:construct_body).with(form, rs, obj1).returns(body_obj)
      get :get_remaining_form_data, form_id: form_id
      response.should be_success
      test_obj = {
          header: {
              left: header_obj[0],
              right: header_obj[1]
          },
          body: body_obj,
          initialSize: 250,
          isCompleted: true,
          formID: form_id,
          errors: {},
          numErrors: 0,
          canView: true
      }
      response.body.should == test_obj.to_json
    end

    it "returns an empty grid if user does not have permission to view form" do
      Permissions.expects(:user_can_see_form_structure?).with(@user, form).returns(false)
      get :get_remaining_form_data, form_id: form_id
      response.should be_success
      test_obj = {
          header: {
              left: [],
              right: []
          },
          body: [],
          initialSize: 250,
          isCompleted: true,
          formID: form_id,
          errors: {},
          numErrors: 0,
          canView: false
      }
      response.body.should == test_obj.to_json
    end

    it "returns an empty grid if user does not have permission to form responses" do
      Permissions.expects(:user_can_see_form_structure?).with(@user, form).returns(true)
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(@user, form).returns(false)
      get :get_remaining_form_data, form_id: form_id
      response.should be_success
      test_obj = {
          header: {
              left: [],
              right: []
          },
          body: [],
          initialSize: 250,
          isCompleted: true,
          formID: form_id,
          errors: {},
          numErrors: 0,
          canView: false
      }
      response.body.should == test_obj.to_json
    end
  end

end