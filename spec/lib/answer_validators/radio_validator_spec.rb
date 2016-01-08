describe AnswerValidators::RadioValidator do
  describe '.validate' do
    let (:question) { FormQuestion.create question_type: 'radio', prompt: 'whatever' }
    let (:o1) { OptionConfig.new index: 0, value: "apples" }
    let (:o2) { OptionConfig.new index: 1, value: "bananas" }
    let (:o3) { OptionConfig.new index: 2, value: "ananas" }

    it "passes if it receives answer included in existing options in the question's config options" do
      question.option_configs = [o1, o2, o3]
      answer = "apples"

      error = AnswerValidators::RadioValidator.validate(question, answer)
      error.should be_nil
    end

    it 'passes for empty answer' do
      AnswerValidators::RadioValidator.validate(nil, "").should be_nil
    end

    it "passes if it receives a yesno answer included in existing options in the question's config options" do
      config1 = OptionConfig.new(index: 2, value: 'no')
      config2 = OptionConfig.new(index: 1, value: 'yes')
      configs = [config1, config2]
      question = FormQuestion.create question_type: 'yesno', option_configs: configs
      answer = "yes"

      error = AnswerValidators::RadioValidator.validate(question, answer)
      error.should be_nil
    end

    it "doesn't pass if it receives answer not included in the question's config options" do
      question.option_configs = [o1, o2, o3]
      answer = "blah"

      error = AnswerValidators::RadioValidator.validate(question, answer)
      error.should == "Invalid options: blah"
    end
  
    it 'works for validate_all' do
      question.option_configs = [o1, o2, o3]
      answers = ["blah", "apples", ""]
      errors = AnswerValidators::RadioValidator.validate_all(question, answers)
      errors[0].should == "Invalid options: blah"
      errors[1].should == nil
      errors[2].should == nil
    end
    
  end
end