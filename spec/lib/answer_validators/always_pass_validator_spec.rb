describe AnswerValidators::AlwaysPassValidator do
  describe '.validate' do
    it 'passes all the times' do
      answer = "answer1"
      error = AnswerValidators::AlwaysPassValidator.validate(nil, answer)
      error.should be_nil
    end

    it 'passes for empty answer' do
      AnswerValidators::AlwaysPassValidator.validate(nil, "").should be_nil
    end

    it 'passes all all the time' do
    	errors = AnswerValidators::AlwaysPassValidator.validate_all(nil, ["1","2","3","blqah blah b;ah"])
    	errors.should == [nil,nil,nil,nil]
    end
  end
end