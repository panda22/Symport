describe FormQuestionUpdater do
  subject { described_class }

  before do
    mock_class Permissions, strict: true
    mock_class FormStructureQuestionReorderer, strict: true
    AuditLogger.stubs(:surround_edit).yields
  end

  describe ".update" do
    let(:project) { Project.create name: "out sweet project" }
    let(:structure) { FormStructure.create! name: "our good form", project: project, form_questions: [question] }
    let(:question) { FormQuestion.create!(
      prompt: "Discouraging prompt",
      description: "Self explanatory",
      variable_name: 'var1',
      sequence_number: 1,
      display_number: "1",
      personally_identifiable: true,
      question_type: "text"
    )}
    let(:user) { User.new }
    let(:data) { {
      prompt: "A new prompt",
      description: "more descriptive",
      sequenceNumber: 4,
      displayNumber: "4",
      variableName: 'var2',
      personallyIdentifiable: false,
      type: "text",
      spuriousProperty: "to be ignored",
      etc: "etc"
    } }

    it "updates a question" do
      question.update_attributes!(
        prompt: "A new prompt",
        description: "more descriptive",
        sequence_number: 4,
        display_number: "4",
        variable_name: 'var2',
        personally_identifiable: false,
        question_type: "text"
      )
      updated_question = question
      updated_structure = FormStructure.new name: "our good form", project: project, form_questions: [updated_question]

      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      reorder_and_serialize = sequence("reorder and serialize")

      FormStructureQuestionReorderer.expects(:reorder).with do |a_structure, a_question|
        a_structure.name.should == "our good form"
        a_question.prompt.should == "A new prompt"
        a_question.sequence_number.should == 4
      end.returns(updated_structure).in_sequence(reorder_and_serialize)
      subject.update(user, question, structure, data).should == updated_structure
      question.reload.prompt.should == "A new prompt"

      question.description.should == "more descriptive"
      question.variable_name.should == "var2"
      question.personally_identifiable.should == false
      question.question_type.should == "text"
    end

    it "logs updating of a question" do
      question.update_attributes!(
        prompt: "A new prompt",
        description: "more descriptive",
        sequence_number: 4,
        display_number: "4",
        variable_name: 'var2',
        personally_identifiable: false,
        question_type: "text"
      )
      updated_question = question
      updated_structure = FormStructure.new name: "our good form", project: project, form_questions: [updated_question]

      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      AuditLogger.expects(:surround_edit).with(user, question).yields
      reorder_and_serialize = sequence("reorder and serialize")

      FormStructureQuestionReorderer.expects(:reorder).with do |a_structure, a_question|
        a_structure.name.should == "our good form"
        a_question.prompt.should == "A new prompt"
        a_question.sequence_number.should == 4
      end.returns(updated_structure).in_sequence(reorder_and_serialize)

      subject.update(user, question, structure, data)
    end

    it "refuses to allow question updates if user lacks form full permission" do
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(false)
      expect {
        subject.update(user, question, structure, data)
      }.to raise_error PayloadException
    end

    it "refuses to allow change from personally_identifiable to not personally_identifiable if user lacks phi viewing permissions" do
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(false)
      begin
        subject.update user, question, structure, data
      rescue ActiveRecord::RecordInvalid => ex
        exception = ex
      end
      exception.should be
      exception.record.errors[:personally_identifiable].should include "You cannot unset the personally identifiable flag for this question"
    end

    it "doesn't blow up when preserving the personally identifiable flag" do
      our_data = data.merge personallyIdentifiable: true
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(false)
      FormStructureQuestionReorderer.stubs(:reorder)
      expect {
        subject.update(user, question, structure, our_data)
      }.not_to raise_error
    end

    it "allows change from personally_identifiable to not personally_identifiable if user has phi viewing permissions" do
      Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      FormStructureQuestionReorderer.stubs(:reorder)
      expect {
        subject.update(user, question, structure, data)
      }.not_to raise_error
    end

    describe "updating in a transaction" do
      before do
        Permissions.expects(:user_can_edit_form_structure?).with(user, structure).returns(true)
        Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      end
      it "rejects changes (including audit log) when update attributes fails" do
        data[:variableName] = "inv@al!d"
        FormStructureQuestionReorderer.expects(:reorder).never
        expect { subject.update(user, question, structure, data) }.to raise_exception ActiveRecord::RecordInvalid
        question.reload.variable_name.should == "var1"
      end

      it "rejects changes (including audit log) when reordering fails" do
        FormStructureQuestionReorderer.stubs(:reorder).raises PayloadException.validation_error("foo")
        expect { subject.update(user, question, structure, data) }.to raise_exception PayloadException
        question.reload.variable_name.should == "var1"
      end
    end
  end
end
