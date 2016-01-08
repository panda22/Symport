describe PasswordResetsController do
  let (:result_user) { {hello: "world"} }
  let (:user) { User.new(email: "2@2.com")}
  let (:rid) { SecureRandom.uuid }
  let (:uid) { SecureRandom.uuid }


  describe "#index" do
    it "returns the User for a password reset" do
      PasswordResetValidator.expects(:is_valid_reset?).with(rid, uid).returns(true)
      User.expects(:find).with(uid).returns(user)
      UserSerializer.expects(:serialize).returns(result_user)
      get :index, rid: rid, uid: uid
      response.should be_success
      response.body.should == {result: true, user: result_user}.to_json
    end

    it "sets result to false if reset is not valid" do
      PasswordResetValidator.expects(:is_valid_reset?).with(rid, uid).returns(false)
      get :index, rid: rid, uid: uid
      response.should be_success
      response.body.should == {result: false, user: nil}.to_json
    end
  end

  describe "#update" do
    let (:password) { "12345ABcd" }
    let (:user_info) { {password: password, passwordConfirmation: password} }

    before do
      user.update_attributes!(first_name: "a", last_name: "b", password: "1234ABCDef", phone_number: "1234567890")
    end

    it "updates the password for the user" do
      PasswordResetValidator.expects(:is_valid_reset?).with(rid, uid).returns(true)
      User.expects(:find).with(uid).returns(user)

      # TODO: get this to work and remove from before
      # User.expects(:update_attributes).with(user_info).returns(true)

      PasswordReset.expects(:where).with(:user_id => uid).returns([])
      PendingUser.expects(:where).with(:user_id => uid).returns([])
      put :update, user: user_info, rid: rid, uid: uid
      response.should be_success
      response.body.should == {result: true}.to_json
    end

    it "sets result to false if password reset is not valid" do
      PasswordResetValidator.expects(:is_valid_reset?).with(rid, uid).returns(false)
      put :update, user: user_info, rid: rid, uid: uid
      response.should be_success
      response.body.should == {result: false}.to_json
    end

    it "sets result to false if user does not exist" do
      PasswordResetValidator.expects(:is_valid_reset?).with(rid, uid).returns(true)
      User.expects(:find).with(uid).returns(nil)
      put :update, user: user_info, rid: rid, uid: uid
      response.should be_success
      response.body.should == {result: false}.to_json
    end

    it "sets result to false if user fails to validate on update_attributes" do
      PasswordResetValidator.expects(:is_valid_reset?).with(rid, uid).returns(true)
      user_info[:password] = "invalidpassword"
      User.expects(:find).with(uid).returns(nil)
      put :update, user: user_info, rid: rid, uid: uid
      response.should be_success
      response.body.should == {result: false}.to_json
    end
  end

  describe "#create" do
    let (:reset) { PasswordReset.new }

    before do
     reset
     user.id = SecureRandom.uuid
    end

    it "creates a new password reset for a user" do
      User.expects(:find_by).with(:email => user.email).returns(user)
      PasswordReset.expects(:new).returns(reset)
      reset.expects(:save).returns(true)
      post :create, user_email: user.email
      response.should be_success
      response.body.should == {result: true}.to_json
    end

    it "sets result to false if user does not exist" do
      User.expects(:find_by).with(:email => user.email).returns(nil)
      post :create, user_email: user.email
      response.should be_success
      response.body.should == {result: false}.to_json
    end

    it "sets result to false if password reset could not save" do
      User.expects(:find_by).with(:email => user.email).returns(user)
      PasswordReset.expects(:new).returns(reset)
      reset.expects(:save).returns(false)
      post :create, user_email: user.email
      response.should be_success
      response.body.should == {result: false}.to_json
    end
  end

end
