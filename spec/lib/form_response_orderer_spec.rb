describe FormResponseOrderer do
  subject { described_class }

  before do
    @form = FormStructure.create!(name: "abcde", is_many_to_one: true, secondary_id: "ab")
    @resp1 = FormResponse.create!(form_structure: @form, subject_id: "a", created_at: DateTime.new(2001,2,3), secondary_id: "2", instance_number: 0)
    @resp2 = FormResponse.create!(form_structure: @form, subject_id: "a", created_at: DateTime.new(2001,2,2), secondary_id: "3", instance_number: 1)
    @resp3 = FormResponse.create!(form_structure: @form, subject_id: "a", created_at: DateTime.new(2001,2,4), secondary_id: "1", instance_number: 2)
  end

  describe "order" do
    it "orders subjects based on date created" do
      @form.is_secondary_id_sorted = false
      FormStructure.expects(:find).with(@form.id).returns(@form)
      instances = subject.order(@resp1)
      instances[0].created_at.should == DateTime.new(2001,2,2)
      instances[0].instance_number.should == 0
    end
  end

  it "orders subjects based on secondary_id" do
    @form.is_secondary_id_sorted = true
    FormStructure.expects(:find).with(@form.id).returns(@form)
    instances = subject.order(@resp1)
    instances[0].secondary_id.should == "1"
    instances[0].instance_number.should == 0
  end
end