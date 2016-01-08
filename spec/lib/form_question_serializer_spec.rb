describe FormQuestionSerializer do
  subject { described_class }
  before do
      FormQuestionConfigSerializer.stubs(:serialize).returns({})
  end
  describe '.serialize' do
    it 'serializes id field' do
      id = SecureRandom.uuid
      rec = FormQuestion.new id: id
      serialized_rec = subject.serialize(rec)
      serialized_rec[:id].should == id
    end

    it 'serializes sequence_number field' do
      rec = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100
      serialized_rec = subject.serialize(rec)
      serialized_rec[:sequenceNumber].should == 100
    end

    it 'serializes form_variable field' do
      rec = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100, variable_name: 'form variable 1'
      serialized_rec = subject.serialize(rec)
      serialized_rec[:sequenceNumber].should == 100
      serialized_rec[:variableName].should == 'form variable 1'
    end

    it 'serializes a personally_identifiable field' do
      rec = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100, personally_identifiable: true
      serialized_rec = subject.serialize(rec)
      serialized_rec[:personallyIdentifiable].should be_true
    end

    it 'serializes a type field' do
      rec = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100, question_type: 'numericalrange'
      serialized_rec = subject.serialize(rec)
      serialized_rec[:type].should == 'numericalrange'
    end

    it 'serializes a prompt field' do
      rec = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100, prompt: 'Prompt1'
      serialized_rec = subject.serialize(rec)
      serialized_rec[:prompt].should == 'Prompt1'
    end

    it 'serializes a description field' do
      rec = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100, description: "Description1"
      serialized_rec = subject.serialize(rec)
      serialized_rec[:description].should == "Description1"
    end

    it 'serializes a config field' do
      question = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100
      serialized_question_config = {size: 'normal'}
      FormQuestionConfigSerializer.expects(:serialize).with(question).returns(serialized_question_config)
      serialized_rec = subject.serialize(question)
      serialized_rec[:config].should == {size: 'normal'}
    end

    it 'serializes conditions' do
      dep_q1 = FormQuestion.new id: SecureRandom.uuid
      dep_q2 = FormQuestion.new id: SecureRandom.uuid
      conds = [
        FormQuestionCondition.new(depends_on: dep_q1, operator: ">", value: '5'),
        FormQuestionCondition.new(depends_on: dep_q2, operator: "=", value: "OK"),
      ]
      question = FormQuestion.new id: SecureRandom.uuid, sequence_number: 100, form_question_conditions: conds
      serialized_question_config = {size: 'normal'}
      FormQuestionConfigSerializer.expects(:serialize).with(question).returns(serialized_question_config)
      serialized_rec = subject.serialize(question)
      serialized_rec[:conditions].should == [
        {dependsOn: dep_q1.id, operator: ">", value: "5"},
        {dependsOn: dep_q2.id, operator: "=", value: "OK"}
      ]
    end
  end

  describe ".validation_errors" do
    it "stuffs errors, then includes config errors" do
      form_question = FormQuestion.new
      form_question.errors[:prompt] << "can't be blank!"
      form_question.errors[:sequence_number] << "something"

      FormQuestionConfigSerializer.expects(:validation_errors).with(form_question).returns "crazy stuff"

      subject.validation_errors(form_question).should == {
        prompt: ["can't be blank!"],
        sequenceNumber: ["something"],
        config: "crazy stuff"
      }
    end
  end
end
