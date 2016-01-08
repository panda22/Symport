describe OptionConfigPresenceValidator do
  subject { described_class }

  describe ".validate" do
    it "doesn't use this validator for the types other than checkbox/yesno/radio/dropdown" do
      question = FormQuestion.create question_type: 'email', display_number: "100", sequence_number: 100, variable_name: "var1", prompt: 'whatever'
      question.errors.should be_empty
      question.option_configs.should be_empty
    end

    context "checkbox" do
      context "valid cases" do
        it "allows creation if at least one valid option is provided" do
            option1 = OptionConfig.create(code: "0", index: 0, value: 'opt1')
            option2 =  OptionConfig.create(code: "1", index: 1, value: 'opt2')
            option3 = OptionConfig.create(code: "2", index: 2, value: 'opt3')
            question = FormQuestion.create question_type: 'checkbox', display_number: "100", sequence_number: 100, variable_name: "var1", prompt: 'whatever', option_configs: [option1, option2, option3]

            question.errors.should be_empty
            question.option_configs.should =~ [option1, option2, option3]
        end
      end
      context "no option config or empty options configs" do
        it "doesn't allow creation with no option" do
          question = FormQuestion.create question_type: 'checkbox', sequence_number: 100, variable_name: "var1", prompt: 'whatever'
          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end

        it "doesn't allow creation if the options are empty strings or nil objects" do
          option1 = OptionConfig.create(code: "0", index: 0, value: '')
          option2 =  OptionConfig.create(code: "1", index: 1, value: nil)
          question = FormQuestion.create question_type: 'checkbox', prompt: 'whatever', option_configs: [option1, option2]

          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end

        it "doesn't allow creation if all the options are empty strings" do
          option1 = OptionConfig.create(index: 0, value: '')
          option2 =  OptionConfig.create(index: 1, value: '')
          option3 = OptionConfig.create(index: 2, value: '')
          question = FormQuestion.create question_type: 'checkbox', prompt: 'whatever', option_configs: [option1, option2, option3]

          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end
      end
    end

    context "dropdown" do
      context "valid cases" do
        it "allows creation if at least one valid option is provided" do
            option1 = OptionConfig.create(code: "0", index: 0, value: 'opt1')
            option2 =  OptionConfig.create(code: "1", index: 1, value: 'opt2')
            option3 = OptionConfig.create(code: "2", index: 2, value: 'opt3')
            question = FormQuestion.create question_type: 'radio', display_number: "100", sequence_number: 100, variable_name: "var1", prompt: 'whatever', option_configs: [option1, option2, option3]

            question.errors.should be_empty
            question.option_configs.should =~ [option1, option2, option3]
        end
      end
      context "no option config or empty options configs" do
        it "doesn't allow creation with no option" do
          question = FormQuestion.create question_type: 'radio', sequence_number: 100, variable_name: "var1", prompt: 'whatever'
          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end

        it "doesn't allow creation if the options are empty strings or nil objects" do
          option1 = OptionConfig.create(index: 0, value: '')
          option2 =  OptionConfig.create(index: 1, value: nil)
          option3 = OptionConfig.create(index: 2, value: '')
          question = FormQuestion.create question_type: 'radio', prompt: 'whatever', option_configs: [option1, option2, option3]

          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end

        it "doesn't allow creation if all the options are empty strings" do
          option1 = OptionConfig.create(index: 0, value: '')
          option2 =  OptionConfig.create(index: 1, value: '')
          option3 = OptionConfig.create(index: 2, value: '')
          question = FormQuestion.create question_type: 'radio', prompt: 'whatever', option_configs: [option1, option2, option3]

          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end
      end
    end

    context "radiobutton" do
      context "valid cases" do
        it "allows creation if at least one valid option is provided" do
            option1 = OptionConfig.create(code: "0", index: 0, value: 'opt1')
            option2 =  OptionConfig.create(code: "1", index: 1, value: 'opt2')
            option3 = OptionConfig.create(code: "2", index: 2, value: 'opt3')
            question = FormQuestion.create question_type: 'radio', display_number: "100", sequence_number: 100, variable_name: "var1", prompt: 'whatever', option_configs: [option1, option2, option3]

            question.errors.should be_empty
            question.option_configs.should =~ [option1, option2, option3]
        end
      end
      context "no option config or empty options configs" do
        it "doesn't allow creation with no option" do
          question = FormQuestion.create question_type: 'radio', sequence_number: 100, variable_name: "var1", prompt: 'whatever'
          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end

        it "doesn't allow creation if the options are empty strings or nil objects" do
          option1 = OptionConfig.create(index: 0, value: '')
          option2 =  OptionConfig.create(index: 1, value: nil)
          option3 = OptionConfig.create(index: 2, value: '')
          question = FormQuestion.create question_type: 'radio', prompt: 'whatever', option_configs: [option1, option2, option3]

          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end

        it "doesn't allow creation if all the options are empty strings" do
          option1 = OptionConfig.create(index: 0, value: '')
          option2 =  OptionConfig.create(index: 1, value: '')
          option3 = OptionConfig.create(index: 2, value: '')
          question = FormQuestion.create question_type: 'radio', prompt: 'whatever', option_configs: [option1, option2, option3]

          question.errors.messages[:option_configs].include? "must have at least one option"
          question.option_configs.should be_empty
        end
      end
    end
  end
end