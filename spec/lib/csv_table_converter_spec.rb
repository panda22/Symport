describe CsvTableConverter do
  subject { described_class }

  describe "convert" do
    it "converts a grid with headers to a csv string" do
      grid = [["1", "2"], ["3", "4"]]
      headers= ["a", "b"]
      result = subject.convert(grid, headers)
      result.should == '"a","b"' + "\n" + '"1","2"' + "\n" + '"3","4"'
    end

    it "converts a grid without headers to a csv string" do
      grid = [["1", "2"], ["3", "4"]]
      result = subject.convert(grid)
      result.should == '"1","2"' + "\n" + '"3","4"'
    end
  end
end