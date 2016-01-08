describe UserController do

  describe "#show" do
    it "finds and renders the user" do
      sign_in

      user = controller.current_user

      UserSerializer.expects(:serialize).returns "serialized user"
      get :show
      response.body.should == {
        user: "serialized user"
      }.to_json
    end
  end

  describe "#update" do
    it "updates the user" do
      sign_in
      user = controller.current_user

      UserUpdater.expects(:update).with(user, "some user info", true).returns "an updated user"
      UserSerializer.expects(:serialize).with("an updated user").returns "a serialized user"

      put :update, user: "some user info"

      response.should be_success
      response.body.should == {user: "a serialized user"}.to_json
    end
  end

  describe "#create" do

    it "saves a record in the database" do
      post :create, user: {
        email: "gb@grizzly-bear.net",
        firstName: "Grizzly",
        lastName: "Bear",
        affiliation: "affil",
        phoneNumber: "1234567890",
        fieldOfStudy: "fos",
        password: "SunInYourEyes1",
        passwordConfirmation: "SunInYourEyes1"
      }, format: :json


      reply = JSON.parse response.body
      session_token = SessionToken.find reply["sessionToken"]
      session_token.should be
      session_token.user.should_not be_nil
      session_token.user.email.should == "gb@grizzly-bear.net"

      user = reply["user"]
      user["email"].should == "gb@grizzly-bear.net"
      user["firstName"].should == "Grizzly"
      user["lastName"].should == "Bear"
      user["affiliation"].should == "affil"
      user["fieldOfStudy"].should == "fos"
    end

    it "complains when there is already a user with that email address" do
      existing_user = User.create! email: "gb@grizzly-bear.net", password: "ABgun1shy", first_name: "grizzly", last_name: "bear", phone_number: "1234567890"

      post :create, user: {
        email: "gb@grizzly-bear.net",
        firstName: "Grizzly",
        lastName: "Bear",
        phoneNumber: "1234567890",
        affiliation: "affil",
        fieldOfStudy: "fos",
        password: "SunInYourEyes1",
        passwordConfirmation: "SunInYourEyes1"
      }, format: :json

      reply = JSON.parse response.body
      response.should_not be_success
      reply["sessionToken"].should be_nil
    end

    it "doesn't allow the email to be blank" do
      post :create, user: {
        email: ""
      }

      response.should_not be_success
    end

  end

end