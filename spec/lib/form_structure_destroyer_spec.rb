describe FormStructureDestroyer do
  subject { described_class }
  let (:user) { User.new }
  let (:question_1) { create :question, display_number: "1", sequence_number: 1, variable_name: "v1", prompt: "p1" }
  let (:question_2) { create :question, display_number: "2", sequence_number: 2, variable_name: "v2", prompt: "p2" }
  let (:response_1) { FormResponse.create subject_id: "123" }
  let (:response_2) { FormResponse.create subject_id: "234" }
  let (:structure) { FormStructure.create name: 'goodbye', form_questions: [question_1, question_2], form_responses: [response_1, response_2] }

  describe '.destroy' do
    it 'deletes the record (and responses and questions)' do
      Permissions.expects(:user_can_delete_form_structure?).with(user, structure).returns(true)
      FormResponseDestroyer.expects(:destroy).with(user, response_1)
      FormResponseDestroyer.expects(:destroy).with(user, response_2)
      structure.deleted_at.should be_nil
      question_1.deleted_at.should be_nil
      question_2.deleted_at.should be_nil
      FormStructureDestroyer.destroy(user, structure)
      structure.deleted_at.should_not be_nil
      question_1.deleted_at.should_not be_nil
      question_2.deleted_at.should_not be_nil
    end

    it "rejects destroying the record if user lacks permission" do
      Permissions.expects(:user_can_delete_form_structure?).with(user, structure).returns(false)
      expect {
        FormStructureDestroyer.destroy(user, structure)
      }.to raise_error PayloadException
    end

    it "logs the delete event for a form structure" do
      seq = sequence("destroy structure")
      Permissions.expects(:user_can_delete_form_structure?).with(user, structure).returns(true).in_sequence(seq)
      FormResponseDestroyer.expects(:destroy).with(user, response_1).in_sequence(seq)
      FormResponseDestroyer.expects(:destroy).with(user, response_2).in_sequence(seq)
      AuditLogger.expects(:remove).with(user, structure).in_sequence(seq)
      FormStructureDestroyer.destroy(user, structure)
    end
  end
end
