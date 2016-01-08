describe FormResponseDestroyer do
  subject { described_class }
  before do
    mock_class AuditLogger
  end

  let (:user) { User.new }
  let (:a1) { FormAnswer.create answer: 'a' }
  let (:a2) { FormAnswer.create answer: 'b' }
  let (:a3) { FormAnswer.create answer: 'c' }
  let (:s1) { FormStructure.create name: "abc" }
  let (:r1) { FormResponse.create subject_id: "abc", form_answers: [a1, a2, a3], form_structure: s1 }

  it 'deletes a form response and all its answers' do
    Permissions.expects(:user_can_delete_form_responses_for_form_structure?).with(user, s1).returns(true)

    r1.deleted_at.should be_nil
    a1.deleted_at.should be_nil
    a2.deleted_at.should be_nil
    a3.deleted_at.should be_nil

    subject.destroy(user, r1)

    r1.deleted_at.should_not be_nil
    a1.deleted_at.should_not be_nil
    a2.deleted_at.should_not be_nil
    a3.deleted_at.should_not be_nil
  end

  it "refuses to delete a response if user lacks access" do
    Permissions.expects(:user_can_delete_form_responses_for_form_structure?).with(user, s1).returns(false)
    expect {
      subject.destroy(user, r1)
    }.to raise_error PayloadException
  end

  it "logs deletion" do
    Permissions.expects(:user_can_delete_form_responses_for_form_structure?).with(user, s1).returns(true)
    AuditLogger.expects(:remove).with(user, r1)
    subject.destroy(user, r1)
  end
end
