describe PasswordResetValidator do
  subject { described_class }

  let (:reset) { PasswordReset.new(id: SecureRandom.uuid, user_id: SecureRandom.uuid) }
  let (:rid) { reset.id }
  let (:uid) { reset.user_id }

  describe "is_valid_reset?" do
    it "returns true for valid reset" do
      reset.created_at = DateTime.current
      PasswordReset.expects(:where).with(:id => rid, :user_id => uid).returns([reset])
      subject.is_valid_reset?(rid, uid).should == true
    end

    it "returns false if reset cannot be found" do
      PasswordReset.expects(:where).with(:id => rid, :user_id => uid).returns([])
      subject.is_valid_reset?(rid, uid).should == false
    end

    it "returns false if reset is more than 2 hours old" do
      reset.created_at = DateTime.current - 3.hours
      PasswordReset.expects(:where).with(:id => rid, :user_id => uid).returns([reset])
      subject.is_valid_reset?(rid, uid).should == false
    end
  end
end