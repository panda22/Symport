describe AnswerValidators::PhoneNumberValidator do
  subject { AnswerValidators::PhoneNumberValidator }

  describe '.validate' do
  let (:question) { FormQuestion.new }
    it 'allows well-formated American phone numbers without parens' do
      subject.validate(question, "616-333-4444").should be_nil
    end

    it 'allows well-formated American phone numbers with parens' do
      subject.validate(question, "(616)-333-4444").should be_nil
    end

    it 'allows well-formated American phone numbers with parens and an extension' do
      subject.validate(question, "(616)-333-4444x12").should be_nil
      subject.validate(question, "(616)-333-4444x1234").should be_nil
    end

    it 'passes for empty answer' do
      subject.validate(nil, "").should be_nil
    end

    it 'does not allow poorly formatted extensions' do
      subject.validate(question, "(616)-333-4444-10").should_not be_nil
      subject.validate(question, "(616)-333-4444 Ext. 10").should_not be_nil
    end

    it 'does not allow leading country codes (including 1)' do
      subject.validate(question, "1-616-333-4444").should_not be_nil
      subject.validate(question, "1-(616)-333-4444").should_not be_nil
      subject.validate(question, "2-(616)-333-4444").should_not be_nil
    end

    it 'rejects for the wrong number of digits in each segment' do
      subject.validate(question, "16-333-4444").should_not be_nil
      subject.validate(question, "1616-333-4444").should_not be_nil
      subject.validate(question, "616-33-4444").should_not be_nil
      subject.validate(question, "616-3333-4444").should_not be_nil
      subject.validate(question, "616-333-444").should_not be_nil
      subject.validate(question, "616-333-44444").should_not be_nil
    end

    it 'rejects no dashes' do
      subject.validate(question, "6163334444").should_not be_nil
    end
  
    it 'works for validate_all' do
      a = ""
      b = "616-333-4444"
      c = "blah"
      errors = subject.validate_all(question,[a,b,c])
      errors[0].should == nil
      errors[1].should == nil
      errors[2].should_not == nil
    end

  end
end
