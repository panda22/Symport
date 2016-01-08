describe FormAnswerProcessor do
  subject { described_class }
  let(:question_1) { FormQuestion.create! question_type: 'text', prompt: "foo bar baz", display_number: "1", sequence_number: 1, variable_name: "variable_1" }
  let(:question_2) { FormQuestion.create! question_type: 'text', prompt: "baz bar foo", display_number: "2", sequence_number: 2, variable_name: "variable_2" }
  let(:question_3) { FormQuestion.create! question_type: 'text', prompt: "another one", display_number: "3", sequence_number: 3, variable_name: "variable_3" }
  let(:structure) { FormStructure.create! name: "Foo", form_questions: [ question_1, question_2 ] }
  let(:answer_1) { FormAnswer.create! answer: "first", form_question: question_1, form_response: form_response }
  let(:answer_2) { FormAnswer.create! answer: "second", form_question: question_2, form_response: form_response }
  let(:answer_3) { FormAnswer.create! answer: "third", form_question: question_3, form_response: form_response }
  let(:form_response) { FormResponse.create! form_structure: structure, subject_id: "abc123" }
  let(:user) { User.new }

  before do
    # make things exist
    answer_1
    answer_2
  end

  describe '.find_or_create_answer' do
    it "finds an existing record" do
      FormRecordCreator.expects(:create_answer).never
      subject.find_or_create_answer(question_1, form_response).should == answer_1
      subject.find_or_create_answer(question_2, form_response).should == answer_2
    end

    it "creates a record when none can be found" do
      answer_3 = FormAnswer.new
      FormRecordCreator.expects(:create_answer).with(question_3).returns answer_3
      subject.find_or_create_answer(question_3, form_response).should == answer_3
    end

    it "works correctly when the response has answers that point to deleted questions" do
      form_response # make sure all the objects are created....
      question_1.destroy

      answer_3 = FormAnswer.create! answer: "what", form_question: question_3, form_response: form_response

      subject.find_or_create_answer(question_3, form_response).should == answer_3
    end
  end

  describe '.validate_and_save_all' do
    it 'validates_all' do
      answer_1.ignore_error = true
      answer_2.ignore_error = true
      answer_3.ignore_error = false
      answer_1.save!
      answer_2.save!
      answer_3.save!

      new_answers = ["first", "new_second", "error"]
      FormAnswerValidator.expects(:validate_all).with(question_1, new_answers).returns([nil,nil,"error stuff"])
      errors = subject.validate_and_save_all(user, question_1, [answer_1,answer_2,answer_3], new_answers)
      
      answer1 = FormAnswer.where(form_question_id: answer_1.form_question_id, form_response_id: answer_1.form_response_id)[0]
      answer2 = FormAnswer.where(form_question_id: answer_2.form_question_id, form_response_id: answer_2.form_response_id)[0]
      answer3 = FormAnswer.where(form_question_id: answer_3.form_question_id, form_response_id: answer_3.form_response_id)[0]
      
      answer1.answer.should == "first"
      answer2.answer.should == "new_second"
      answer3.answer.should == "error"
      
      answer1.ignore_error.should == true
      answer2.ignore_error.should == false
      answer3.ignore_error.should == false      

      answer1.error_msg.should be_nil
      answer2.error_msg.should be_nil
      answer3.error_msg.should_not be_nil

      errors.should == [nil,nil,"error stuff"]

    end

  end

  describe '.validate_and_save' do
    it "validates the record, saving a valid answer and returning nil, and setting ignore_error to false on value change" do
      answer_1.ignore_error = true
      answer_1.save!
      FormAnswerValidator.expects(:validate).with(question_1, "ichiban").returns(nil)
      subject.validate_and_save(user, question_1, answer_1, "ichiban").should be_nil
      answer_1.reload.answer.should == "ichiban"
      answer_1.ignore_error.should == false
    end

    it "validates the record, saving a valid answer and returning nil, and leaing ignore_error unchanged on same value" do
      answer_1.ignore_error = true
      answer_1.answer = "ichiban"
      answer_1.save!
      FormAnswerValidator.expects(:validate).with(question_1, "ichiban").returns(nil)
      subject.validate_and_save(user, question_1, answer_1, "ichiban").should be_nil
      answer_1.reload.answer.should == "ichiban"
      answer_1.ignore_error.should == true
    end

    it "validates the record, saving an answer on error and returning the error" do
      FormAnswerValidator.expects(:validate).with(question_1, "ichiban").returns("some error")
      subject.validate_and_save(user, question_1, answer_1, "ichiban").should == "some error"
      answer_1.reload.answer.should == "ichiban"
      answer_1.error_msg.should == "some error"
    end
  end

  describe '.validate' do
    it "validates the record, not saving a valid answer and returning nil" do
      new_answer = FormAnswer.new answer: "new", form_question: question_2, form_response: form_response 
      FormAnswerValidator.expects(:validate).with(question_1, new_answer.answer).returns(nil)
      subject.validate(user, question_1, new_answer, new_answer.answer).should be_nil
      raises_not_found do new_answer.reload end
    end

    it "validates the record, not saving an answer, and returning the error" do
      new_answer = FormAnswer.new answer: "new", form_question: question_2, form_response: form_response 
      FormAnswerValidator.expects(:validate).with(question_1, new_answer.answer).returns({"not" => "gonna do it"})
      subject.validate(user, question_1, new_answer, new_answer.answer).should == {"not" => "gonna do it"}
      raises_not_found do new_answer.reload end
    end
  end

  def raises_not_found(opts={})
    expect { 
      yield if block_given? 
    }.to raise_error ActiveRecord::RecordNotFound 
  end

end
