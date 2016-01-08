describe SessionTokenTools do
  subject { described_class }

  describe '.create_token' do
    it 'will return a token if passed a valid user' do
      user = User.create email: "dq@dq.com", password: "super fancy password"
      created_token = subject.create_token(user)
      created_token.should_not be_nil
      created_token.user == user
      created_token.last_activity_at > 1.second.ago.round
    end

    it 'will return nil if passed a nil user' do
      created_token = subject.create_token(nil)
      created_token.should be_nil
    end
  end


  describe ".find_valid_token" do

    it "finds and returns tokens that have not expired" do
      user = User.create email: "chris@chrisfarber.net"
      valid_token = SessionToken.create user: user
      invalid_token = SessionToken.create user: user
      nonexisting_id = SecureRandom.uuid

      SessionTokenTools.stubs(:token_valid?).with { |token| token.id == valid_token.id }.returns true
      SessionTokenTools.stubs(:token_valid?).with { |token| token.id == invalid_token.id }.returns false

      subject.find_valid_token(valid_token.id).should == valid_token
      subject.find_valid_token(invalid_token.id).should == nil
      subject.find_valid_token(nonexisting_id).should == nil
    end

    it "updates activity when desired" do
      user = User.create email: "chris@chrisfarber.net"
      token_last_activity = Time.now.round.in_time_zone
      token = SessionToken.create user: user, last_activity_at: token_last_activity
      SessionTokenTools.stubs(:token_valid?).returns true

      subject.find_valid_token(token.id, false)
      token.reload.last_activity_at.should == token_last_activity

      sleep 5 # FIXME
      subject.find_valid_token(token.id, true)
      token.reload.last_activity_at.should > token_last_activity
    end

    it "never updates the last_activity_at of an invalid token" do
      user = User.create email: "chris@chrisfarber.net"
      # as an example, this value is irrelevant except in that it should not change:
      original_expired_last_activity_at = 4.days.ago.round
      invalid_token = SessionToken.create user: user, last_activity_at: original_expired_last_activity_at

      SessionTokenTools.stubs(:token_valid?).returns false

      subject.find_valid_token(invalid_token.id, true)

      invalid_token.reload.last_activity_at.should == original_expired_last_activity_at
    end

  end

  describe ".token_valid?" do

    it "approves tokens whose last_activity_at is within the last 15 minutes" do
      Timecop.freeze Time.local(2014, 6, 2, 10, 15) do
        token = SessionToken.new last_activity_at: 10.minutes.ago.round
        subject.token_valid?(token).should be_true

        token.last_activity_at = 20.minutes.ago.round
        subject.token_valid?(token).should be_false

        token.last_activity_at = 15.minutes.ago.round
        subject.token_valid?(token).should be_true

        token.last_activity_at = 5.minutes.ago.round
        subject.token_valid?(token).should be_true

        token.last_activity_at = 5.minutes.from_now.round
        subject.token_valid?(token).should be_true

        token.last_activity_at = 2.days.ago.round
        subject.token_valid?(token).should be_false
      end
    end

  end

  describe ".destroy_token" do
    before do
      user = User.create email: "dq@dq.com"
      @token = SessionToken.create user: user, last_activity_at: Time.now.round
    end
    it "successfully deletes current token" do
      SessionTokenTools.destroy_token(@token)
      expect {@token.reload}.to raise_exception
    end

    it "fails in deleting current_token" do
      SessionToken.any_instance.stubs(:destroy).raises(Exception, "Something went wrong!")
      @token.persisted?.should be_true
    end
  end

end
