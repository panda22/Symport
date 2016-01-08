describe AnswerValidators::DateValidator do
  describe '.validate' do
    it 'passes if the format is correct' do
      answer = "08/29/1989"

      error = AnswerValidators::DateValidator.validate(nil, answer)
      error.should be_nil
    end

    it "doesn't pass if the format is not correct" do
      answer = "08/29-1989"

      error = AnswerValidators::DateValidator.validate(nil, answer)
      error.should == "Please enter a valid date in the format mm/dd/yyyy"
    end

    it 'passes for empty answer' do
      AnswerValidators::DateValidator.validate(nil, "").should be_nil
    end

    it "doesn't pass if the format is correct but the month isn't a valid one" do
      answer = "13/29/1989"

      error = AnswerValidators::DateValidator.validate(nil, answer)
      error.should == "Please enter a valid date in the format mm/dd/yyyy"
    end

    it "doesn't pass if the format is correct but it's not a valid date" do
      answer = "02/29/1900" #Please enter a valid date in the format mm/dd/yyyy

      error = AnswerValidators::DateValidator.validate(nil, answer)
      error.should == "Please enter a valid date in the format mm/dd/yyyy"
    end

    it "works for validate_all" do
      answer1 = "02/20/1900" #Please enter a valid date in the format mm/dd/yyyy
      answer2 = "13/29/1989"
      answer3 = "08/29/1989"
      answer4 = "08/29-1989"
      answer5 = ""
      errors = AnswerValidators::DateValidator.validate_all(nil, [answer1,answer2,answer3,answer4,answer5])
      errors[0].should == nil
      errors[1].should == "Please enter a valid date in the format mm/dd/yyyy"
      errors[2].should == nil
      errors[3].should == "Please enter a valid date in the format mm/dd/yyyy"
      errors[4].should == nil
    end

  end
end