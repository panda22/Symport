describe FormQuestionCreator do
  subject { described_class }

  before do
    mock_class FormRecordCreator, strict: true
    mock_class FormStructureQuestionReorderer, strict: true
    mock_class AuditLogger
  end

  describe '.create' do
    let(:user) { User.new }
    let(:question_data) { { prompt: 'foo', description: 'bar' } }
    let(:new_question) { FormQuestion.new prompt: 'something', variable_name: "varOK", question_type: "zipcode", sequence_number: 3, display_number: "3" }
    let(:old_question1) { FormQuestion.create! question_type: 'text', prompt: "old one", variable_name: "variable_1", sequence_number: 1, display_number: "1" }
    let(:old_question2) { FormQuestion.create! question_type: 'text', prompt: "old two", variable_name: "variable_1", sequence_number: 2, display_number: "2" }
    let(:updated_question1) { FormQuestion.create! question_type: 'text', prompt: "updated one", variable_name: "variable_1", sequence_number: 1, display_number: "1" }
    let(:updated_question2) { FormQuestion.create! question_type: 'text', prompt: "updated two", variable_name: "variable_2", sequence_number: 2, display_number: "2" }
    let(:structure) { FormStructure.create! name: 'Formica', form_questions: [old_question1, old_question2] }
    let(:updated_structure) { FormStructure.new id: structure.id, name: 'Formica', form_questions: [updated_question1, updated_question2] }

    it 'creates a question given data, adds it to the structure, and reorders' do
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      seq = sequence('question-create')
      FormRecordCreator.expects(:create_question).with(question_data, structure).returns(new_question).in_sequence(seq)
      FormStructureQuestionReorderer.expects(:reorder).with(structure, new_question, old_question2.id).returns(updated_structure).in_sequence(seq)
      subject.create(user, structure, question_data, old_question2.id).should == updated_structure
    end

    it 'creates a question with an out of order question number and reorders and make sure that serializer has the updated structure including the question with the RIGHT question number' do
      new_question = FormQuestion.new question_type: 'text', prompt: "something", variable_name: "something", sequence_number: 100

      new_question_after_reordering = FormQuestion.create! question_type: 'text', prompt: "something", variable_name: "something", sequence_number: 100, display_number: "100"
      updated_structure = FormStructure.new id: structure.id, name: 'Formica', form_questions: [updated_question1, updated_question2, new_question_after_reordering]

      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      seq = sequence('question-create')
      FormRecordCreator.expects(:create_question).with(question_data, structure).returns(new_question).in_sequence(seq)
      FormStructureQuestionReorderer.expects(:reorder).with(structure, new_question, old_question2.id).returns(updated_structure).in_sequence(seq)
      subject.create(user, structure, question_data, old_question2.id).should == updated_structure
    end

    it "rejects creating a question when user lacks permissions" do
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(false)
      expect {
        subject.create(user, structure, question_data)
      }.to raise_error PayloadException
    end

    it "logs creation of a form question" do
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      seq = sequence('question-create')
      FormRecordCreator.expects(:create_question).with(question_data, structure).returns(new_question).in_sequence(seq)
      AuditLogger.expects(:add).with(user, new_question)
      FormStructureQuestionReorderer.expects(:reorder).with(structure, new_question, old_question2.id).returns(updated_structure).in_sequence(seq)
      subject.create(user, structure, question_data, old_question2.id).should == updated_structure
    end

    describe "makes changes in a transaction" do
      it "rejects changes if reordering fails" do
        id = ""
        Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
        seq = sequence('question-create')
        FormRecordCreator.expects(:create_question).with(question_data, structure) do |data, struct|
          new_question.save!
          id = new_question.id
        end.returns(new_question).in_sequence(seq)
        AuditLogger.expects(:add).with(user, new_question)
        FormStructureQuestionReorderer.expects(:reorder).with(structure, new_question, old_question2.id).raises PayloadException.validation_error("foo")
        expect { subject.create(user, structure, question_data, old_question2.id) }.to raise_error PayloadException
        expect { FormQuestion.find(id) }.to raise_error ActiveRecord::RecordNotFound
      end

      it "rejects changes if audit logging failed" do
        id = "abc"
        Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
        seq = sequence('question-create')
        FormRecordCreator.expects(:create_question).with(question_data, structure) do |data, struct|
          new_question.save!
          id = new_question.id
        end.returns(new_question).in_sequence(seq)
        AuditLogger.expects(:add).raises PayloadException.validation_error("bar")
        expect { subject.create(user, structure, question_data) }.to raise_error PayloadException
        expect { FormQuestion.find(id) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

end
