describe FormQuestionConditionValidator do
  subject { described_class.new }

  describe '#validate' do
    let(:form) { FormStructure.create! name: "Formy" }
    let(:question) { create :question, form_structure: form, sequence_number: 2, display_number: "2" }
    it 'accepts when depends on question is valid and in same form as form question' do
      ref = create :question, form_structure: form, sequence_number: 1, display_number: "1"
      rec = FormQuestionCondition.new form_question: question, depends_on: ref
      subject.validate(rec)
      rec.errors[:depends_on].should be_empty
    end

    it 'accepts when form question is absent (presence handled separately)' do
      ref = create :question, form_structure: form, sequence_number: 1, display_number: "1"
      rec = FormQuestionCondition.new depends_on: ref
      subject.validate(rec)
      rec.errors[:depends_on].should be_empty
    end

    it 'accepts when depends on is absent (presence handled separately)' do
      ref = create :question, form_structure: form, sequence_number: 1, display_number: "1"
      rec = FormQuestionCondition.new form_question: question
      subject.validate(rec)
      rec.errors[:depends_on].should be_empty
    end

    it 'rejects when depends on does not belong to the same form as form question' do
      form2 = FormStructure.create! name: "FormZ"
      ref = create :question, form_structure: form2, sequence_number: 1, display_number: "1"
      rec = FormQuestionCondition.new form_question: question, depends_on: ref
      subject.validate(rec)
      rec.errors[:depends_on].should == ["Depends on question must be in same form as this question"]
    end

    it 'rejects when depends on is later than owning question' do
      ref = create :question, form_structure: form, sequence_number: 3, display_number: "3"
      rec = FormQuestionCondition.new form_question: question, depends_on: ref
      subject.validate(rec)
      rec.errors[:depends_on].should == ["Depends on question must be earlier in the form than this question"]
    end
  end
end
