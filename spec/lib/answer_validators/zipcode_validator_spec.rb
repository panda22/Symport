describe AnswerValidators::ZipcodeValidator do
  describe '.validate' do
    it 'passes when passed any five digit number' do
      answer = '12345'
      error = AnswerValidators::ZipcodeValidator.validate(nil, answer)
      error.should be_nil
    end

    it "doesn't pass if passed any number with less or more than 5 digits" do
      answer1 = '123'
      answer2 = '123456'
      error1 = AnswerValidators::ZipcodeValidator.validate(nil, answer1)
      error2 = AnswerValidators::ZipcodeValidator.validate(nil, answer2)
      error1.should == "Please enter a valid Zip Code"
      error2.should == "Please enter a valid Zip Code"
    end

    it 'passes for empty answer' do
      AnswerValidators::ZipcodeValidator.validate(nil, "").should be_nil
    end

    it "doesn't pass if passed a string which containts characters" do
      answer1 = "12345f"
      answer2 = "f12345"
      answer3 = "ffffff"
      error1 = AnswerValidators::ZipcodeValidator.validate(nil, answer1)
      error2 = AnswerValidators::ZipcodeValidator.validate(nil, answer2)
      error3 = AnswerValidators::ZipcodeValidator.validate(nil, answer3)
      error1.should == "Please enter a valid Zip Code"
      error2.should == "Please enter a valid Zip Code"
      error3.should == "Please enter a valid Zip Code"
    end

    it 'works for validate_all' do
      errors = AnswerValidators::ZipcodeValidator.validate_all(nil,["12345","","blah"])
      errors.should == [nil,nil,"Please enter a valid Zip Code"]
    end
  end
end