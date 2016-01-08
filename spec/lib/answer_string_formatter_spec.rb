describe AnswerStringFormatter do
  subject { described_class }

  describe "format" do
    it "keeps the answer the same if it isn't empty or blocked" do
      result = subject.format("abc", nil, "", "")
      result.should == "abc"
    end

    it "changes the answer to blocked code if it is special blocked char" do
      result = subject.format("\u200D", nil, "EMPTY", "BLOCKED")
      result.should == "BLOCKED"
    end

    it "changes the answer to empty code if it is nil" do
      result = subject.format(nil, nil, "EMPTY", "BLOCKED")
      result.should == "EMPTY"
    end

    it "changes the answer to empty code if it is empty string" do
      result = subject.format("", nil, "EMPTY", "BLOCKED")
      result.should == "EMPTY"
    end
  end
end