describe AnswerTypeConverter do
  subject { described_class }

  describe "convert" do
    # EMTPY CASES
    it "returns nil if answer is nil" do
      result = subject.convert(nil, "text")
      result.should == nil
    end

    it "returns nil if answer is emtpy string" do
      result = subject.convert("", "text")
      result.should == nil
    end

    it "returns nil if type is nil" do
      result = subject.convert('a', nil)
      result.should == nil
    end

    it "returns nil if type is empty string" do
      result = subject.convert('a', "")
      result.should == nil
    end

    # NUMERICAL RANGE
    it "converts a  string to a float" do
      result = subject.convert("12.12", "numericalrange")
      result.should == 12.12
    end

    it "returns nil if answer is not a valid float" do
      result = subject.convert("", "numericalrange")
      result.should == nil
    end

    # TIME DURATION
    it "converts a time duration string to the total number of seconds" do
      result = subject.convert("03:21:21", "timeduration")
      result.should == 12081
    end

    it "returns nil if time duration is ill-formatted" do
      result = subject.convert("ab:21rr21", "timeduration")
      result.should == nil
    end

    # TIME OF DAY
    it "converts time of day to a DateTime object" do
      result = subject.convert("12:21 AM", "timeofday")
      result.class.should == DateTime
      result.should == DateTime.parse("12:21 AM")
    end

    it "returns nil for an ill-formatted string" do
      result = subject.convert("ab:cd PM", "timeofday")
      result.should == "ab:cd PM"
    end

    # DATE
    it "converts date to a DateTime object" do
      result = subject.convert("12/21/2011", "date")
      result.class.should == Date
      result.should == Date.strptime("12/21/2011", "%m/%d/%Y")
    end

    it "returns original string for an exception string" do
      result = subject.convert("99/99/9999", "date")
      result.should == "99/99/9999"
    end

    it "returns nil if date is ill-formatted" do
      result = subject.convert("ab/cd/efgh", "date")
      result.should == nil
    end

    # PHONE NUMBER
    it "returns nil if answer is ()--" do
      result = subject.convert("()--", "phonenumber")
      result.should == nil
    end

    it "returns the phone number otherwise" do
      result = subject.convert("(777)-777-7777", "phonenumber")
      result.should == "(777)-777-7777"
    end

    # DEFAULT (any other question type)
    it "returns the same answer given" do
      result = subject.convert("abc", "text")
      result.should == "abc"
    end
  end
end