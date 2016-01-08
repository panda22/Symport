describe AnswerValidators::NumericalRangeValidator do
  subject { AnswerValidators::NumericalRangeValidator }

  describe '.validate' do
    let (:number_range) do
      NumericalRangeConfig.new({
        minimum_value: 10.5,
        maximum_value: 23.4,
        precision: '2'
      })
    end
    let (:question) { FormQuestion.new numerical_range_config: number_range }

    it 'accepts values (inclusively) inside the range and at least as precise as specified and reject others' do
      subject.validate(question, "14").should == "Your value must have at least 2 decimal places"
      #subject.validate(question, 14).should == "Your value must have at least 2 decimal places"
      subject.validate(question, "14.5").should == "Your value must have at least 2 decimal places"
      subject.validate(question, "10.53").should be_nil
      subject.validate(question, "23.4").should == "Your value must have at least 2 decimal places"
      subject.validate(question, "20.00").should be_nil
    end

    it 'passes for empty answer' do
      subject.validate(nil, "").should be_nil
    end

    it "works for other precisions" do
      number_range.update_attributes! precision: "4"

      subject.validate(question, "14.5").should == "Your value must have at least 4 decimal places"
      subject.validate(question, "14.5000").should be_nil
    end

    it "accepts only integer values inside the range for precision set to 0" do
      number_range = NumericalRangeConfig.new({ minimum_value: 10.5, maximum_value: 23.4, precision: '0' })
      new_question = FormQuestion.new numerical_range_config: number_range
      subject.validate(new_question, "14").should be_nil
      subject.validate(new_question, "14.4").should == "Your value must be a whole number"
      subject.validate(new_question, "40.4").should == "40.4 is greater than 23.4, please enter a number in the specified range"
    end

    it 'rejects values greater than max' do
      subject.validate(question, "114.00").should == "114.00 is greater than 23.4, please enter a number in the specified range"
      subject.validate(question, "403.34").should == "403.34 is greater than 23.4, please enter a number in the specified range"
    end

    it 'rejects values less than min' do
      subject.validate(question, "4.00").should == "4.00 is less than 10.5, please enter a number in the specified range"
      subject.validate(question, "3.34").should == "3.34 is less than 10.5, please enter a number in the specified range"
    end

    it 'works for validate_all' do
      number_range = NumericalRangeConfig.new({ minimum_value: 10.5, maximum_value: 23.4, precision: '0' })
      new_question = FormQuestion.new numerical_range_config: number_range
      errors = subject.validate_all(new_question, ["14","","14.4"])
      errors.should == [nil,nil,"Your value must be a whole number"]
    end

  end
end
