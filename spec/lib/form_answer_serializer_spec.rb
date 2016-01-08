describe FormAnswerSerializer do

  subject { described_class }

  before do
    mock_class FormQuestionSerializer
  end

  describe '.serialize' do
    let (:answer) { FormAnswer.new answer: 'an answer' }
    let (:question) { FormQuestion.new personally_identifiable: true }

    describe 'answer value' do
      context 'phi data' do
        let (:question) { FormQuestion.new personally_identifiable: true }
        it 'includes data if can_phi is true' do
          serialized = subject.serialize(answer, question, true)
          serialized[:answer].should == 'an answer'
          serialized[:filtered].should be_false
        end
        it 'filters data if can_phi is false' do
          serialized = subject.serialize(answer, question, false)
          serialized[:answer].should be_nil
          serialized[:filtered].should be_true
        end
      end

      context 'not phi data' do
        let (:question) { FormQuestion.new personally_identifiable: false }
        it 'includes data if can_phi is true' do
          serialized = subject.serialize(answer, question, true)
          serialized[:answer].should == 'an answer'
          serialized[:filtered].should be_false
        end
        it 'includes data if can_phi is false' do
          serialized = subject.serialize(answer, question, false)
          serialized[:answer].should == 'an answer'
          serialized[:filtered].should be_false
        end
      end
    end

    it 'serializes associated question' do
      FormQuestionSerializer.stubs(:serialize).returns('serialized q')
      serialized = subject.serialize(answer, question, false)
      serialized[:question] == 'serialized q'
    end

    it 'works with no answer' do
      FormQuestionSerializer.stubs(:serialize).returns('serialized q')
      serialized = subject.serialize(nil, question, false)
      serialized.should == { answer: nil, filtered: true, question: 'serialized q', errorMessage: nil}
    end
  end
end
