describe FormResponsesGridSerializer do
  describe ".serialize" do
    it "serializes each response" do
      user = User.new
      resp1 = FormResponse.new
      resp2 = FormResponse.new
      resp3 = FormResponse.new
      FormResponseSerializer.expects(:serialize).with(user, resp1).returns("serialized_resp1")
      FormResponseSerializer.expects(:serialize).with(user, resp2).returns("serialized_resp2")
      FormResponseSerializer.expects(:serialize).with(user, resp3).returns("serialized_resp3")
      serialized_responses = FormResponsesGridSerializer.serialize(user, [resp1, resp2, resp3])
      serialized_responses.should == ["serialized_resp1", "serialized_resp2",  "serialized_resp3"]
    end
  end
end
