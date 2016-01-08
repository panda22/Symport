describe AnswerValidators::TimeOfDayValidator do
  describe '.validate' do
    it "passes if passed a correct time of day" do
      answer = "12:54 AM"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should be_nil

      answer = "12:59 pm"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should be_nil

      answer = "2:38 PM"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should be_nil
    end

    it 'passes for empty answer' do
      AnswerValidators::TimeOfDayValidator.validate(nil, "").should be_nil
    end

    it "doesn't pass if passed incorrect time of day" do
      answer = "23:10 PM"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"

      answer = "98:56 PM"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"

      answer = "98:99 PM"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"

      answer = "23:10das"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"

      answer = "12:10"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"

      answer = "12:59 pmd"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"

      answer = "12/593 pm"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"

      answer = "12/593pm"
      error = AnswerValidators::TimeOfDayValidator.validate(nil, answer)
      error.should == "Please enter a valid time of day in the format HH:MM AM/PM"
    end

    it 'works for validate_all' do
      errors = AnswerValidators::TimeOfDayValidator.validate_all(nil, ["12:59 pm","","blah"])
      errors.should == [nil,nil,"Please enter a valid time of day in the format HH:MM AM/PM"]
    end

  end
end
