describe FormQuestionAnswerUpdater do
  subject { described_class }
  describe '.update' do
    let (:question_1) { FormQuestion.create variable_name: 'var1', sequence_number: 1, display_number: "1", question_type: 'text', prompt: 'something' }
    let (:question_2) { FormQuestion.create variable_name: 'var2', sequence_number: 2, display_number: "2", question_type: 'text', prompt: 'something else' }
    let (:question_3) { FormQuestion.create variable_name: 'var3', sequence_number: 3, display_number: "3", question_type: 'text', prompt: 'and another thing' }
    let (:found_answer) { FormAnswer.new }
    let (:new_answer) { FormAnswer.new }
    let (:form_response) { FormResponse.new }
    let (:answers_array) {
      [
        {question: question_1.id, answer: 'one'},
        {question: question_2.id, answer: 'two'},
        {question: question_3.id, answer: 'three'}
      ]
    }
    let (:user) { User.new }

    it "updates an answer record" do
      FormAnswerProcessor.expects(:find_or_create_answer).with(question_2, form_response).returns(found_answer)
      FormAnswerProcessor.expects(:validate_and_save).with(user, question_2, found_answer, 'two').returns(nil)
      subject.update(user, question_2, form_response, answers_array).should == {}
    end

    it "returns well-formed errors" do
      FormAnswerProcessor.expects(:find_or_create_answer).with(question_2, form_response).returns(found_answer)
      FormAnswerProcessor.expects(:validate_and_save).with(user, question_2, found_answer, 'two').returns("error")
      subject.update(user, question_2, form_response, answers_array).should == {1 => {answer: "error"}}
    end

    it "handles new questions with no data for the answer" do
      question_4 = FormQuestion.create variable_name: "var4", sequence_number: 4, display_number: "4", question_type: 'text', prompt: "and another day"
      FormAnswerProcessor.expects(:find_or_create_answer).with(question_4, form_response).returns(new_answer)
      FormAnswerProcessor.expects(:validate_and_save).with(user, question_4, new_answer, nil).returns(nil)
      subject.update(user, question_4, form_response, answers_array).should == {}
    end
  end

  describe '.validate' do
    let (:question_1) { FormQuestion.create! variable_name: 'var1', sequence_number: 1, display_number: "1", question_type: 'text', prompt: 'something' }
    let (:question_2) { FormQuestion.create! variable_name: 'var2', sequence_number: 2, display_number: "2", question_type: 'text', prompt: 'something else' }
    let (:question_3) { FormQuestion.create! variable_name: 'var3', sequence_number: 3, display_number: "3", question_type: 'text', prompt: 'and another thing' }
    let (:found_answer) { FormAnswer.new }
    let (:new_answer) { FormAnswer.new }
    let (:form_response) { FormResponse.new }
    let (:answers_array) {
      [
        {question: question_1.id, answer: 'one'},
        {question: question_2.id, answer: 'two'},
        {question: question_3.id, answer: 'three'}
      ]
    }
    let (:user) { User.new }

    it "returns well-formed errors" do
      FormAnswerProcessor.expects(:get_new_answer).with(question_2).returns(found_answer)
      FormAnswerProcessor.expects(:validate).with(user, question_2, found_answer, 'two').returns("error")
      subject.validate(user, question_2, answers_array).should == {1 => {answer: "error"}}
    end
  end
end
