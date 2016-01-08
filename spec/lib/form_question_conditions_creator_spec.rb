describe FormQuestionConditionsCreator do
  subject { described_class }

  describe '.create' do
    it 'successfully creates question conditions' do
      structure = FormStructure.create! name: "My Form"
      q1 = create :question, form_structure: structure, sequence_number: 2, display_number: "2", variable_name: "v2"
      q2 = create :question, form_structure: structure, sequence_number: 3, display_number: "3", variable_name: "v3"
      qc1 = FormQuestionCondition.new depends_on_id: q1, operator: "<>", value: "apple"
      qc2 = FormQuestionCondition.new depends_on_id: q2, operator: "<=", value: "10"
      data =
          [
            { dependsOn: q1.id, operator: "<>", value: "apple" },
            { dependsOn: q2.id, operator: "<=", value: "10" }
          ]

      QuestionConditionsValidator.expects(:validate)
      question_conditions = subject.create(data)
      question_conditions.count.should == 2

      question_conditions[0].errors.messages.should be_empty
      question_conditions[0].depends_on_id.should == q1.id
      question_conditions[0].operator.should == "<>"
      question_conditions[0].value.should == "apple"

      question_conditions[1].errors.messages.should be_empty
      question_conditions[1].depends_on_id.should == q2.id
      question_conditions[1].operator.should == "<="
      question_conditions[1].value.should == "10"
    end


    it 'rejects invalid conditions' do
      data = [
        { dependsOn: SecureRandom.uuid, operator: "<>", value: "apple" },
        { dependsOn: SecureRandom.uuid, operator: "<=", value: "10" }
      ]
      errors = {0=>{:value=>"Question does not exist"}}
      QuestionConditionsValidator.expects(:validate).raises PayloadException.new(422, { validations: { conditions: errors } })
      expect { subject.create(data) }.to raise_error PayloadException
    end
  end
end