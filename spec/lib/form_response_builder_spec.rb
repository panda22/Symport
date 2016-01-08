describe FormResponseBuilder do
  subject { described_class }
  describe '.build' do
    before do
      mock_class FormRecordCreator, strict: true
      Permissions.stubs(:user_can_enter_form_responses_for_form_structure?).returns(true)
      AuditLogger.stubs(:add)
    end
    let (:q1) { FormQuestion.create! display_number: "1", sequence_number: 1, prompt: "p1", question_type: "text", variable_name: "v1" }
    let (:q2) { FormQuestion.create! display_number: "2", sequence_number: 2, prompt: "p2", question_type: "text", variable_name: "v2" }
    let (:q3) { FormQuestion.create! display_number: "3", sequence_number: 3, prompt: "p3", question_type: "text", variable_name: "v3" }
    let (:a1) { FormAnswer.create! form_question: q1, answer: 'a' }
    let (:a2) { FormAnswer.create! form_question: q2, answer: 'b' }
    let (:a3) { FormAnswer.create! form_question: q3, answer: 'c' }
    let (:structure) { FormStructure.create! name: "s1", form_questions: [q1, q2, q3] }
    let (:subject_id) { "abc123" }
    let (:user) { User.new }

    it 'builds a new form response based on a structure' do
      response = subject.build(user, structure, subject_id)
      response.id.should be_nil
      response.subject_id.should == "abc123"
      response.form_structure.should == structure
      response.form_answers.map(&:form_question).should =~ [q1,q2,q3]
    end

    it "refuses to build a new response when user lacks access" do
      Permissions.expects(:user_can_enter_form_responses_for_form_structure?).with(user, structure).returns(false)
      expect {
        subject.build(user, structure, subject_id)
      }.to raise_error PayloadException
    end

    it "omits formatting questions" do
      formatting_q = create :question, question_type: "header", display_number: "555"
      structure.form_questions << formatting_q
      response = subject.build(user, structure, subject_id)
      response.form_answers.map(&:form_question).should_not include(formatting_q)
    end
  end
end
