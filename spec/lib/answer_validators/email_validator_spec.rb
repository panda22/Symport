describe AnswerValidators::EmailValidator do
  describe '.validate' do
    it "passes if passed a correct email address" do
      answer = "john@smith.com"
      error = AnswerValidators::EmailValidator.validate(nil, answer)
      error.should be_nil
    end

    it "doesn't pass if the email is not in a valid format" do
      answer1 = "john@smith"
      error1 = AnswerValidators::EmailValidator.validate(nil, answer1)
      error1.should == "Please enter a valid email in the format example@xyz.com"

      answer2 = "john"
      error2 = AnswerValidators::EmailValidator.validate(nil, answer2)
      error2.should == "Please enter a valid email in the format example@xyz.com"

      answer3 = "@smith.com"
      error3 = AnswerValidators::EmailValidator.validate(nil, answer3)
      error3.should == "Please enter a valid email in the format example@xyz.com"
    end

    it 'passes for empty answer' do
      AnswerValidators::EmailValidator.validate(nil, "").should be_nil
    end

    it 'works for validate_all' do
      a = "john@smith.com"
      b = ""
      c = "blah"
      errors = AnswerValidators::EmailValidator.validate_all(nil, [a,b,c])
      errors.should == [nil, nil, "Please enter a valid email in the format example@xyz.com"]
    end

  end
end