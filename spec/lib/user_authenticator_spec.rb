describe UserAuthenticator do
  subject { described_class }

  describe '.find_and_authenticate' do
    it "successfully finds a user" do
      user = User.create! email: "dq@dq.com", password: "Complex1", first_name: "David", last_name: "Qorashi", phone_number: "1234567890"
      AuditLogger.expects(:user_entry).with(user, "sign_in", data: { ipAddress: '1.2.3.4', email: "dq@dq.com" })
      found_user = subject.find_and_authenticate("dq@dq.com", "Complex1", '1.2.3.4')

      found_user.should_not be_false
      found_user.email.should == "dq@dq.com"
      found_user.password.should be_nil
    end

    it "doesn't find a user" do
      user = User.create! email: "dq@dq.com", password: "Complex1", first_name: "David", last_name: "Qorashi", phone_number: "1234567890"
      AuditLogger.expects(:user_entry).with(user, "sign_in_failed", data: { ipAddress: '1.2.3.4', email: "dq@dq.com" })
      found_user = subject.find_and_authenticate "dq@dq.com", "this password is incorrect", "1.2.3.4"

      found_user.should be_false

      AuditLogger.expects(:user_entry).with(user, "sign_in_failed", data: { ipAddress: '2.3.4.5', email: "dq@dq.com" })
      another_attempt = subject.find_and_authenticate "dq@dq.com", nil, '2.3.4.5'
      another_attempt.should be_false
    end

    it "doesn't blow up when there is no such user" do
      AuditLogger.expects(:user_entry).with(nil, "sign_in_failed", data: { ipAddress: '1.2.3.4', email: "nope@nope.com" })
      found_user = subject.find_and_authenticate "nope@nope.com", "nope", "1.2.3.4"
      found_user.should be_false
    end
  end
end
