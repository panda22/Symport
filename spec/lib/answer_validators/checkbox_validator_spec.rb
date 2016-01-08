describe AnswerValidators::CheckboxValidator do
  describe '.validate' do
    let (:question) { FormQuestion.create question_type: 'checkbox', prompt: 'whatever' }
    let (:o1) { OptionConfig.new index: 0, value: "apples" }
    let (:o2) { OptionConfig.new index: 1, value: "bananas" }
    let (:o3) { OptionConfig.new index: 2, value: "ananas" }
    let (:o4) { OptionConfig.new index: 3, value: "ananas,watermelon" }

    before do
      question.option_configs = [o1, o2, o3, o4]
    end

    it 'passes for empty answer' do
      AnswerValidators::CheckboxValidator.validate(nil, "").should be_nil
    end

    it "passes if it receives answers included existing options in the question's config options" do
      answer = "apples#{"\u200C"}bananas"

      error = AnswerValidators::CheckboxValidator.validate(question, answer)
      error.should be_nil
    end

    it "passes if it receives answers (sepearated by comma) included in the questions's config options" do
      answer = "ananas,watermelon"

      error = AnswerValidators::CheckboxValidator.validate(question, answer)
      error.should be_nil
    end

    it "doesn't pass if it receives answers not included in the question's config options" do
      answer = "apples#{"\u200C"}bananas#{"\u200C"}oranges#{"\u200C"}peach"

      error = AnswerValidators::CheckboxValidator.validate(question, answer)
      error.should == "Invalid options: oranges peach"

      answer = "blah1#{"\u200C"}blah2"

      error = AnswerValidators::CheckboxValidator.validate(question, answer)
      error.should == "Invalid options: blah1 blah2"
    end

    it 'works for validate_all' do
      answer1 = "apples#{"\u200C"}bananas"
      answer2 = "bananas#{"\u200C"}not_an_answer"
      answer3 = ""
      errors = AnswerValidators::CheckboxValidator.validate_all(question, [answer1,answer2,answer3])
      errors[0].should be_nil
      errors[1].should == "Invalid options: not_an_answer"
      errors[2].should be_nil
    end
  end
end
