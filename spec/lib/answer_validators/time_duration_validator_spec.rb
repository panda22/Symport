describe AnswerValidators::TimeDurationValidator do
  subject { AnswerValidators::TimeDurationValidator }
  let(:question) { FormQuestion.new }

  describe '.validate' do
    it 'accepts time values greater than 0' do
      subject.validate(question, "00:00:00").should be_nil
      subject.validate(question, "0:0:0").should be_nil
      subject.validate(question, "1:1:1").should be_nil
      subject.validate(question, "0:1:1").should be_nil
      subject.validate(question, "1:0:1").should be_nil
      subject.validate(question, "1:1:0").should be_nil
    end

    it 'passes for empty answer' do
      subject.validate(nil, "").should be_nil
    end

    it 'rejects time values less than 0' do
      subject.validate(question, "-1:-1:-1").should == "Invalid time duration"
    end

    it 'rejects integer time values' do
      subject.validate(question, 101).should == "Invalid time duration"
      subject.validate(question, "101").should == "Invalid time duration"
    end

    it 'rejects string values' do
      subject.validate(question, "invalid:time").should == "Invalid time duration"
    end

    it 'rejects too long of values' do
      subject.validate(question, "123:1234:123456").should be_nil
      subject.validate(question, "1234:1234:123456").should == "Invalid time duration"
      subject.validate(question, "123:12345:123456").should == "Invalid time duration"
      subject.validate(question, "123:1234:1234567").should == "Invalid time duration"
      subject.validate(question, "1234:12345:1234567").should == "Invalid time duration"
    end

    it 'works for validate_all' do
      errors = subject.validate_all(question, ["0:0:0","","blah"])
      errors.should == [nil,nil,"Invalid time duration"]
    end

  end
end
