describe FormQuestionDestroyer do
  subject { described_class }

  describe '.destroy' do
    let(:question) { FormQuestion.create! question_type: "text", prompt: 'something', sequence_number: 5, display_number: "5", variable_name: "v5" }
    let(:keep_question_1) { FormQuestion.create! question_type: "text", prompt: 'one', sequence_number: 1, display_number: "1", variable_name: "v1"  }
    let(:keep_question_2) { FormQuestion.create! question_type: "text", prompt: 'two', sequence_number: 2, display_number: "2", variable_name: "v2"  }
    let(:structure) { FormStructure.create! name: 'whatev', form_questions: [keep_question_1, question, keep_question_2] }
    let(:updated_structure) { FormStructure.create! name: 'whatev2' }
    let(:user) { User.new }

    it 'destroys the given question from structure' do
      mock_class FormStructureQuestionReorderer, strict: true
      mock_class AuditLogger
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      seq = sequence('question-destroy')
      question.expects(:destroy!).in_sequence(seq)
      FormStructureQuestionReorderer.expects(:reorder).with(structure).returns(updated_structure)#.in_sequence(seq)
      subject.destroy(user, question, structure).should == updated_structure
    end

    it 'logs destroying of a question' do
      mock_class FormStructureQuestionReorderer, strict: true
      mock_class AuditLogger
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      seq = sequence('question-destroy')
      question.expects(:destroy!).in_sequence(seq)
      AuditLogger.expects(:remove).with(user, question).in_sequence(seq)
      FormStructureQuestionReorderer.expects(:reorder).with(structure).returns(updated_structure).in_sequence(seq)
      subject.destroy(user, question, structure).should == updated_structure
    end

    it 'refuses to destroy the question if user lacks access' do
      mock_class FormStructureQuestionReorderer, strict: true
      mock_class AuditLogger
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(false)
      expect {
        subject.destroy(user, question, structure)
      }.to raise_error PayloadException
    end

    context "question conditions" do
      before do
        mock_class FormStructureQuestionReorderer, strict: true
        mock_class AuditLogger
        Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
        FormStructureQuestionReorderer.expects(:reorder).with(structure).returns(updated_structure)
      end
      it "destroys any conditions that depend on this question" do
        dependent_q_1 = create :question, variable_name: "foo", sequence_number: 6, display_number: "6", form_structure: structure
        dependent_q_2 = create :question, variable_name: "bar", sequence_number: 8, display_number: "8", form_structure: structure
        condition_1 = FormQuestionCondition.create! form_question: dependent_q_1, depends_on: question, operator: "=", value: "1"
        condition_2 = FormQuestionCondition.create! form_question: dependent_q_2, depends_on: question, operator: ">", value: "2"
        subject.destroy(user, question, structure)
        question.should be_destroyed
        [condition_1, condition_2, dependent_q_1, dependent_q_2].each(&:reload)
        condition_1.should be_destroyed
        condition_2.should be_destroyed
        dependent_q_1.should_not be_destroyed
        dependent_q_2.should_not be_destroyed
      end

      it "destroys any conditions that use this question" do
        dependency_q_1 = create :question, variable_name: "foo", sequence_number: 2, display_number: "2", form_structure: structure
        dependency_q_2 = create :question, variable_name: "bar", sequence_number: 3, display_number: "3", form_structure: structure
        condition_1 = FormQuestionCondition.create! form_question: question, depends_on: dependency_q_1, operator: "=", value: "1"
        condition_2 = FormQuestionCondition.create! form_question: question, depends_on: dependency_q_2, operator: ">", value: "2"
        subject.destroy(user, question, structure)
        question.should be_destroyed
        [condition_1, condition_2, dependency_q_1, dependency_q_2].each(&:reload)
        condition_1.should be_destroyed
        condition_2.should be_destroyed
        dependency_q_1.should_not be_destroyed
        dependency_q_2.should_not be_destroyed
      end
    end

    describe "making changes in a transaction" do
      it "rejects all changes if reordering fails" do
        question1 = create :question, prompt: 'foo', sequence_number: 1, variable_name: "foo", display_number: "1"
        question2 = create :question, prompt: 'bar', sequence_number: 2, variable_name: "bar", display_number: "2"
        question3 = create :question, prompt: 'baz', sequence_number: 3, variable_name: "foobar", display_number: "3"
        cond_q2 = FormQuestionCondition.create! form_question: question2, depends_on: question1, operator: "=", value: "something"
        cond_q3 = FormQuestionCondition.create! form_question: question3, depends_on: question2, operator: "<>", value: "nothing"
        structure = FormStructure.create! name: 'whatever', form_questions: [question1, question2, question3]

        Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
        AuditLogger.expects(:remove).with(user, question1)
        FormStructureQuestionReorderer.expects(:reorder).with(structure).raises PayloadException.validation_error("something")

        expect { subject.destroy(user, question1, structure) }.to raise_error PayloadException

        question1.reload.should_not be_destroyed
        cond_q2.reload.should_not be_destroyed
      end
    end
  end
end
