describe FormResponseUpdater do
  subject { described_class }
  before do
    mock_class FormResponseAnswersUpdater, strict: true
  end
  describe '.update' do
    let (:question1) { FormQuestion.create prompt: 'Foo?', sequence_number: 1, question_type: 'zipcode' }
    let (:answer1) { FormAnswer.create answer: 'foo', form_question: question1 }
    let (:question2) { FormQuestion.create prompt: 'Bar?', sequence_number: 2, question_type: 'email' }
    let (:answer2) { FormAnswer.create answer: 'bar', form_question: question2 }
    let (:question3) { FormQuestion.create prompt: 'Baz?', sequence_number: 3, question_type: 'email' }
    let (:answer3) { FormAnswer.create answer: 'baz', form_question: question3 }
    let (:structure) { FormStructure.create name: 'structcha', form_questions: [question1, question2, question3] }
    let (:form_response) { FormResponse.create form_structure: structure, form_answers: [answer1, answer2, answer3] }
    let (:user) { User.new }
    let (:data) { {   answers: [1, 2, 3]   } }

    it 'updates answers' do
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, structure).returns(true)
      FormResponseAnswersUpdater.expects(:update).with(user, form_response, data[:answers]).returns("serialized form answers")
      subject.update(user, form_response, data).should == form_response
    end

    it "refuses to update answers when user lacks permissions" do
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, structure).returns(false)
      expect {
        subject.update(user, form_response, data)
      }.to raise_error PayloadException
    end

    it "updates 2 responses in many_to_one form with same subject but different instance numbers" do
      other_structure = FormStructure.create(name: 'structcha', form_questions: [question1, question2, question3], is_many_to_one: true, secondary_id: "sid")
      response1 = FormResponse.create(form_structure: other_structure, form_answers: [answer1, answer2, answer3], instance_number: 0)
      response2 = FormResponse.create(form_structure: other_structure, form_answers: [answer1, answer2, answer3], instance_number: 1)
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, other_structure).returns(true)
      FormResponseAnswersUpdater.expects(:update).with(user, response1, data[:answers]).returns("serialized form answers")
      subject.update(user, response1, data).should == response1
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, other_structure).returns(true)
      FormResponseAnswersUpdater.expects(:update).with(user, response2, data[:answers]).returns("serialized form answers")
      subject.update(user, response2, data).should == response2
    end

    it "orders instances if is_secondary_id is true" do
      other_structure = FormStructure.create(name: 'structcha', form_questions: [question1, question2, question3], is_many_to_one: true, secondary_id: "sid", is_secondary_id_sorted: true)
      response1 = FormResponse.create(form_structure: other_structure, form_answers: [answer1, answer2, answer3], instance_number: 0)
      response2 = FormResponse.create(form_structure: other_structure, form_answers: [answer1, answer2, answer3], instance_number: 0)
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, other_structure).returns(true)
      FormResponseAnswersUpdater.expects(:update).with(user, response1, data[:answers]).returns("serialized form answers")
      FormResponseOrderer.expects(:order).with(response1)
      subject.update(user, response1, data).should == response1
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, other_structure).returns(true)
      FormResponseAnswersUpdater.expects(:update).with(user, response2, data[:answers]).returns("serialized form answers")
      FormResponseOrderer.expects(:order).with(response2)
      subject.update(user, response2, data).should == response2
    end
  end

  describe '.get-errors' do
    let (:question1) { FormQuestion.create prompt: 'Foo?', sequence_number: 1, question_type: 'zipcode' }
    let (:answer1) { FormAnswer.create answer: 'foo', form_question: question1 }
    let (:question2) { FormQuestion.create prompt: 'Bar?', sequence_number: 2, question_type: 'email' }
    let (:answer2) { FormAnswer.create answer: 'bar', form_question: question2 }
    let (:question3) { FormQuestion.create prompt: 'Baz?', sequence_number: 3, question_type: 'email' }
    let (:answer3) { FormAnswer.create answer: 'baz', form_question: question3 }
    let (:structure) { FormStructure.create name: 'structcha', form_questions: [question1, question2, question3] }
    let (:form_response) { FormResponse.create form_structure: structure, form_answers: [answer1, answer2, answer3] }
    let (:user) { User.new }
    let (:data) { {   answers: [1, 2, 3]   } }

    it 'updates answers' do
      FormResponseAnswersUpdater.expects(:get_errors).with(user, form_response, data[:answers]).returns("serialized form answers")
      subject.get_errors(user, form_response, data).should == form_response
    end

  end



end
