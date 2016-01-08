describe QuestionConditionsValidator do
  subject { described_class }

  describe ".validate" do
    context "validates successfully" do
      it "validates if passed an empty list of question conditions" do
        expect { subject.validate([]) }.to_not raise_error
      end

      it "validates form question conditions" do
        structure = FormStructure.create! name: "My Form"
        q1 = FormQuestion.create! question_type: "email", prompt: "Email Question", form_structure: structure, sequence_number: 1, display_number: "1", variable_name: "var1"
        qc1 = FormQuestionCondition.new depends_on_id: q1, operator: "==", value: "john@smithcom"
        qc2 = FormQuestionCondition.new depends_on_id: q1, operator: "<>", value: "anna@smith.com"

        FormAnswerValidator.expects(:validate).with(q1, qc1.value)
        FormAnswerValidator.expects(:validate).with(q1, qc2.value)

        expect { subject.validate([qc1, qc2]) }.to_not raise_error
      end
    end

    context "rejects" do
      it "rejects if parent question is not found" do
        qc1 = FormQuestionCondition.new depends_on_id: SecureRandom.uuid, operator: "==", value: "john@smithcom"
        expect { subject.validate([qc1]) }.to raise_error { |err|
          err.class.should == PayloadException
          err.error[:validations][:conditions][0].should have_key(:dependsOn)
          err.error[:validations][:conditions][0][:dependsOn].should == "Question does not exist"
        }
      end

      it "rejects if the value of the condition is not consistent with the parent question type" do
        structure = FormStructure.create! name: "My Form"
        q1 = FormQuestion.create! question_type: "email", prompt: "Email Question", form_structure: structure, sequence_number: 1, display_number: "1", variable_name: "var1"
        qc1 = FormQuestionCondition.new depends_on_id: q1, operator: "==", value: "john"
        qc2 = FormQuestionCondition.new depends_on_id: q1, operator: "<>", value: "anna@smith.com"
        qc3 = FormQuestionCondition.new depends_on_id: q1, operator: "<>", value: "doo@gmail"

        FormAnswerValidator.expects(:validate).with(q1, qc1.value).returns("Please enter a valid email in the format example@xyz.com")
        FormAnswerValidator.expects(:validate).with(q1, qc2.value).returns(nil)
        FormAnswerValidator.expects(:validate).with(q1, qc3.value).returns("Please enter a valid email in the format example@xyz.com")

        expect { subject.validate([qc1, qc2, qc3]) }.to raise_error { |err|
          err.class.should == PayloadException
          err.error[:validations][:conditions][0].should have_key(:value)
          err.error[:validations][:conditions][0][:value].should == "Please enter a valid email in the format example@xyz.com"
          err.error[:validations][:conditions][2].should have_key(:value)
          err.error[:validations][:conditions][2][:value].should == "Please enter a valid email in the format example@xyz.com"
        }
      end
    end
  end
end