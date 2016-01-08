describe FormResponseLookup do
  subject { described_class }
  before do
    Permissions.stubs(:user_can_view_form_responses_for_form_structure?).returns true
  end
  let (:user) { User.new }
  let (:form_structure) { FormStructure.create! name: "Formy" }

  describe '#find_response' do
    let (:form_response) { FormResponse.create!(form_structure: form_structure, subject_id: 'a1') }

    it "returns a form response" do
      subject.find_response(user, form_response.id).should == form_response
    end

    it "rejects loading response when user lacks access" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, form_structure).returns false
      expect {
        subject.find_response(user, form_response.id)
      }.to raise_error PayloadException
    end

    it "raises an error when no record exists" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).never
      Permissions.expects(:user_can_see_form_structure?).never
      expect {
        subject.find_response(user, SecureRandom.uuid)
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#form_response_by_subject_id' do
    let (:subject_id) { "abc123" }
    let (:form_response) { FormResponse.create!(form_structure: form_structure, subject_id: subject_id, instance_number: 0) }
    let (:form_response2) { FormResponse.create!(form_structure: form_structure, subject_id: subject_id, instance_number: 1) }

    before do
      form_response
      form_response2
    end

    it "returns a form response" do
      subject.find_response_by_subject_id(user, form_structure.id, subject_id, 0).should == form_response
    end

    it "returns a form_response with instance_number > 0" do
      subject.find_response_by_subject_id(user, form_structure.id, subject_id, 1).should == form_response2
    end

    it "rejects loading response when user lacks access" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, form_structure).returns false
      expect {
        subject.find_response_by_subject_id(user, form_structure.id, subject_id, 0)
      }.to raise_error PayloadException
    end

    it "returns nil when no record exists" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).never
      Permissions.expects(:user_can_see_form_structure?).never
      subject.find_response_by_subject_id(user, form_structure.id, "oops subject", 0).should be_nil
    end
  end

  describe "#get_max_instances_in_form" do
    it "gets the max number of responses for a subject in a form" do
      resp1 = FormResponse.new(:subject_id => "1", :instance_number => 0)
      resp2 = FormResponse.new(:subject_id => "1", :instance_number => 1)
      resp3 = FormResponse.new(:subject_id => "2", :instance_number => 0)
      new_form = FormStructure.create!(:name => "abcde", :form_responses => [resp1, resp2, resp3])
      subject.get_max_instances_in_form(new_form.id).should == 2
    end

    it "returns 0 if form has no responses" do
      new_form = FormStructure.create!(:name => "yay")
      subject.get_max_instances_in_form(new_form.id).should == 0
    end

    it "returns 0 if form does not exist" do
      subject.get_max_instances_in_form(SecureRandom.uuid).should == 0
    end
  end
end
