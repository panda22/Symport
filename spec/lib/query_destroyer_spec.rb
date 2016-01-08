describe QueryDestroyer do
  subject { described_class }

  let (:query) { Query.create!(name: "abc") }
  let (:query_id) { query.id }
  let (:param1) { QueryParam.create!(query: query) }
  let (:param1_id) { param1.id }
  let (:param2) { QueryParam.create!(query: query) }
  let (:param2_id) { param2.id }
  let (:query_form1) { QueryFormStructure.create!(query: query) }
  let (:query_form1_id) { query_form1.id }
  let (:query_form2) { QueryFormStructure.create!(query: query) }
  let (:query_form2_id) { query_form2.id }
  let(:user) { User.new }

  before do
    query
    param1
    param2
    query_form1
    query_form2
  end

  describe "destroy" do
    it "destroys a query" do
      Permissions.expects(:user_can_delete_query?).with(user, query).returns(true)
      subject.destroy(query, user)
      Query.where(id: query_id).length.should == 0
    end

    it "destroys all the params for a query" do
      Permissions.expects(:user_can_delete_query?).with(user, query).returns(true)
      subject.destroy(query, user)
      Query.where(id: query_id).length.should == 0
      QueryParam.where(query_id: query_id).length.should == 0
    end

    it "destroys all the query_forms for a query" do
      Permissions.expects(:user_can_delete_query?).with(user, query).returns(true)
      subject.destroy(query, user)
      Query.where(id: query_id).length.should == 0
      QueryFormStructure.where(query_id: query_id).length.should == 0
    end

    it "raises an error if user does not have permission to delete query" do
      Permissions.expects(:user_can_delete_query?).with(user, query).returns(false)
      expect {
        subject.destroy(query, user)
      }.to raise_error PayloadException
    end
  end
end