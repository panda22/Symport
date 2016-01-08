describe EmailValidator do
  subject { described_class }
  describe ".validate" do
    it 'accepts a correct email address' do
      errors = subject.validate("david.qorashi@ao.com")
      errors.should be_nil
    end

    it 'rejects an invalid email address' do
      errors = subject.validate("email")
      errors.should == "Please enter a valid email in the format example@xyz.com"
    end
  end
end