describe SessionController do
  describe '#create' do
    before do
      mock_class UserAuthenticator, strict: true
      request.env['REMOTE_ADDR'] = '1.2.3.4'
    end
    it 'registers a new session token with success' do
      user_info = { email: 'john@smith.com', password: 'What3ver', phone_number: "1234567890"}
      user = mock "user"
      a_session_token = mock "session token"
      a_session_token.expects(:id).returns "this-is-an-id"

      UserAuthenticator.expects(:find_and_authenticate).with("john@smith.com", "What3ver", "1.2.3.4").returns(user)
      SessionTokenTools.expects(:create_token).with(user).returns(a_session_token)
      UserSerializer.expects(:serialize).with(user).returns "serialized user info"
      post :create, user: user_info, format: :json
      response.should be_success
      response.body.should == {sessionToken: "this-is-an-id", user: "serialized user info", success: true}.to_json
    end

    it 'handle failure for authenticate' do
      UserAuthenticator.expects(:find_and_authenticate).with("user@gmail.com", "What3ver", "1.2.3.4").returns(false)
      post :create, user: { email: 'user@gmail.com', password: 'What3ver', phone_number: "12345678890"}, format: :json
      response.status.should == 401
      response.body.should == {success: false}.to_json
    end

  end

  describe '#destroy' do

    it "deletes the token if there is a token" do
      user = User.create email: "john@smith.com", password: "ABtest12", first_name: "eh", last_name: "meh", phone_number: "12345678"
      token = SessionToken.create(last_activity_at: Time.now.round, user: user)
      SessionTokenTools.expects(:destroy_token).with(token).returns(true)

      AuditLogger.expects(:user_entry).with(user, "sign_out")

      request.headers["X-LabCompass-Auth"] = token.id
      delete :destroy, format: :json
      response.should be_success
    end

  end

  describe "#valid" do
    it "returns truthiness but doesn't touch the last_activity_at" do
      user = User.create email: "john@smith.com", password: "ABtest12", first_name: "john", last_name: "smith"
      time = 10.minutes.ago.round
      token = SessionToken.create last_activity_at: time, user: user

      request.headers["X-LabCompass-Auth"] = token.id
      get :valid, format: :json

      response.should be_success
      reply = JSON.parse response.body
      reply["active"].should be_true

      token.reload.last_activity_at.should == time
    end

    it "returns false value for no session" do
      get :valid, format: :json

      response.should be_success
      reply = JSON.parse response.body
      reply["active"].should be_false
    end
  end

end
