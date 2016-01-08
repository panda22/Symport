describe FormAnswerValidator do
  describe 'validate' do
    it 'accepts any answer for question type text' do
      question = FormQuestion.create question_type: 'text', prompt: 'whatever'
      answer = "whatever"

      AnswerValidators::AlwaysPassValidator.expects(:validate).with(question, answer).returns nil
      errors = FormAnswerValidator.validate(question, answer)
      errors.should be_nil
    end

    context 'date type' do
      let(:question) { FormQuestion.create question_type: 'date', prompt: 'whatever' }
      it 'passes if passed a valid answer' do
        answer = "08/29/1989"

        AnswerValidators::DateValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed a not valid answer" do
        question = FormQuestion.create question_type: 'date', prompt: 'whatever'
        answer = "08/29/89"

        AnswerValidators::DateValidator.expects(:validate).with(question, answer).returns "not a correct date"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not a correct date"
      end
    end

    context 'zipcode type' do
      let(:question) { FormQuestion.create question_type: 'zipcode', prompt: 'whatever' }
      it 'passes if passed a valid answer' do
        answer = "49534"

        AnswerValidators::ZipcodeValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed a not valid answer" do
        answer = "111"

        AnswerValidators::ZipcodeValidator.expects(:validate).with(question, answer).returns "not a correct zipcode"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not a correct zipcode"
      end
    end

    context 'email type' do
      let(:question) { FormQuestion.create question_type: 'email', prompt: 'whatever' }
      it 'passes if passed a valid answer' do
        answer = "foo@bar.com"

        AnswerValidators::EmailValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed a not valid answer" do
        answer = "bad.email@"

        AnswerValidators::EmailValidator.expects(:validate).with(question, answer).returns "not a correct email"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not a correct email"
      end
    end

    context 'checkbox type' do
      let(:question) { FormQuestion.create question_type: 'checkbox', prompt: 'whatever' }
      let(:option1) { OptionConfig.create(index: 3, value: 'blah1') }
      let(:option2) { OptionConfig.create(index: 2, value: 'blah2') }
      let(:option3) { OptionConfig.create(index: 3, value: 'blah3') }

      it 'passes if passed some valid answers' do
        question.option_configs = [option1, option2, option3]
        answer = "blah2,blah3"
        AnswerValidators::CheckboxValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed an invalid answer" do
        question.option_configs = [option1, option2, option3]

        answer = "blah4"
        AnswerValidators::CheckboxValidator.expects(:validate).with(question, answer).returns "not existed in defined options"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not existed in defined options"
      end
    end

    context 'radio type' do
      let(:question) { FormQuestion.create question_type: 'radio', prompt: 'whatever' }
      let(:option1) { OptionConfig.create(index: 3, value: 'blah1') }
      let(:option2) { OptionConfig.create(index: 2, value: 'blah2') }
      let(:option3) { OptionConfig.create(index: 3, value: 'blah3') }

      it 'passes if passed a valid answer' do
        question.option_configs = [option1, option2, option3]

        answer = "blah1"
        AnswerValidators::RadioValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed an invalid answer" do
        question.option_configs = [option1, option2, option3]

        answer = "blah4"
        AnswerValidators::RadioValidator.expects(:validate).with(question, answer).returns "not existed in defined options"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not existed in defined options"
      end
    end

    context 'dropdown' do
      let(:question) { FormQuestion.create question_type: 'dropdown', prompt: 'whatever' }
      let(:option1) { OptionConfig.create(index: 3, value: 'blah1') }
      let(:option2) { OptionConfig.create(index: 2, value: 'blah2') }
      let(:option3) { OptionConfig.create(index: 3, value: 'blah3') }

      it 'passes if passed a valid answer' do
        question.option_configs = [option1, option2, option3]

        answer = "blah1"
        AnswerValidators::DropdownValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed an invalid answer" do
        question.option_configs = [option1, option2, option3]

        answer = "blah4"
        AnswerValidators::DropdownValidator.expects(:validate).with(question, answer).returns "not existed in defined options"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not existed in defined options"
      end
    end

    context 'time of day type' do
      let(:question) { FormQuestion.create question_type: 'timeofday', prompt: 'whatever' }
      it 'passes if passed a valid answer' do
        answer = "12:00 AM"
        AnswerValidators::TimeOfDayValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed an an invalid answer" do
        answer = "23:00 AM"
        AnswerValidators::TimeOfDayValidator.expects(:validate).with(question, answer).returns "not correct format"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not correct format"
      end
    end

    context 'time duration type' do
      let(:question) { FormQuestion.create question_type: 'timeduration', prompt: 'whatever' }
      it 'passes if passed a valid answer' do
        answer = "12:12:43"
        AnswerValidators::TimeDurationValidator.expects(:validate).with(question, answer).returns nil
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end

      it "doesn't pass if passed an an invalid answer" do
        answer = ":12:43"
        AnswerValidators::TimeDurationValidator.expects(:validate).with(question, answer).returns "not correct format"
        errors = FormAnswerValidator.validate(question, answer)
        errors.should == "not correct format"
      end
    end

    context "header or other unknown type" do
      subject { described_class }
      it "does nothing" do
        header = FormQuestion.create question_type: "header", prompt: "this is a header!"
        other = FormQuestion.create question_type: "not-real", prompt: "this is not a real question type"

        subject.validate(header, "").should be_nil
        subject.validate(other, nil).should be_nil
      end
    end

    context "empty answers" do
      let(:question) { FormQuestion.create question_type: 'timeduration', prompt: 'whatever' }
      it "allows empty answers without even checking validators" do
        answer = ""
        AnswerValidators::TimeDurationValidator.expects(:validate).never
        errors = FormAnswerValidator.validate(question, answer)
        errors.should be_nil
      end
    end
  end
end
