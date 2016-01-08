describe FormBuilderLookup do
  subject { described_class }
  before do
    Permissions.stubs(:user_can_see_form_structure?).returns true
  end

  let (:user) { User.new }
  let (:form_structure) { FormStructure.create! name: "Formy" }

  describe '#find_question' do
    let (:form_question) { FormQuestion.create!(prompt: "whatever", variable_name: "var1", sequence_number: 1, display_number: "1", question_type: "text", form_structure: form_structure) }
    it "returns a form question" do
      subject.find_question(user, form_question.id).should == form_question
    end

    it "rejects loading question when user lacks access" do
      Permissions.expects(:user_can_see_form_structure?).with(user, form_structure).returns false
      expect {
        subject.find_question(user, form_question.id)
      }.to raise_error PayloadException
    end

    it "raises an error when no record exists" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).never
      Permissions.expects(:user_can_see_form_structure?).never
      expect {
        subject.find_question(user, SecureRandom.uuid)
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#find_structure' do
    it "returns a form structure" do
      subject.find_structure(user, form_structure.id).should == form_structure
    end

    it "rejects loading structure when user lacks access" do
      Permissions.expects(:user_can_see_form_structure?).with(user, form_structure).returns false
      expect {
        subject.find_structure(user, form_structure.id)
      }.to raise_error PayloadException
    end

    it "raises an error when no record exists" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).never
      Permissions.expects(:user_can_see_form_structure?).never
      expect {
        subject.find_structure(user, SecureRandom.uuid)
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

end
