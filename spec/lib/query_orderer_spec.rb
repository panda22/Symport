describe QueryOrderer do
  subject { described_class }

  describe "order" do

    let (:last_updated_query) { Query.new(name: "n", updated_at: DateTime.new(2001,2,3)) }
    let (:first_updated_query) { Query.new(name: "m", updated_at: DateTime.new(2001,2,1)) }
    let (:first_alphabetical_query) { Query.new(name: "a", updated_at: DateTime.new(2001,2,2)) }
    let (:last_alphabetical_query) { Query.new(name: "z", updated_at: DateTime.new(2001,2,2)) }
    let (:all_queries) { [first_updated_query, last_updated_query, first_alphabetical_query, last_alphabetical_query] }

    it "sorts by recently updated first" do
      result = subject.order(all_queries, "editedDescending")
      result[0].name.should == "n"
      result[3].name.should == "m"
    end

    it "sorts by recently updated last" do
      result = subject.order(all_queries, "editedAscending")
      result[0].name.should == "m"
      result[3].name.should == "n"
    end

    it "sorts in alphabetical order of name" do
      result = subject.order(all_queries, "a-z")
      result[0].name.should == "a"
      result[3].name.should == "z"
    end

    it "sorts in reverse alphabetical order of name" do
      result = subject.order(all_queries, "z-a")
      result[0].name.should == "z"
      result[3].name.should == "a"
    end

    it "defaults to editedDescending" do
      result = subject.order(all_queries, "I am not a recognized type")
      result[0].name.should == "n"
      result[3].name.should == "m"
    end

  end
end