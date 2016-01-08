describe ApplicationController do

  describe "authentication helpers" do
    controller do
      skip_before_filter :header_authenticate!, only: :create
      before_filter :form_authenticate!, only: :create

      def index
        render json: {hello: current_user.email}
      end

      def create
        render json: {hello: current_user.email}
      end

    end

    context 'header authentication' do
      it "renders a 401 when authenticating if an invalid token is provided, or none at all" do
        get :index
        response.status.should == 401

        request.headers["X-LabCompass-Auth"] = "some-invalid-id"
        get :index
        response.status.should == 401
      end

      it "lets you through with a valid token" do
        user = User.create! email: "billy@bob.com", password: "ABsigh12", first_name: "oh", last_name: "yeah", phone_number: "1234567890"
        valid_token = SessionToken.create user: user, last_activity_at: 4.minutes.ago

        request.headers["X-LabCompass-Auth"] = valid_token.id
        get :index
        response.should be_success
        response.body.should == {hello: "billy@bob.com"}.to_json
      end

      it "doesn't let you through with an expired token" do
        user = User.create email: "billy@bob.com", password: "ABsigh12"
        invalid_token = SessionToken.create user: user, last_activity_at: 30.minutes.ago

        request.headers["X-LabCompass-Auth"] = invalid_token.id
        get :index
        response.status.should == 401
      end
    end

    context 'form authenication' do
      it "renders a 401 when authenticating if an invalid token is provided, or none at all" do
        post :create
        response.status.should == 401

        post :create, "X-LabCompass-Auth" => "some-invalid-id"
        response.status.should == 401
      end

      it "lets you through with a valid token" do
        user = User.create! email: "billy@bob.com", password: "ABsigh12", first_name: "oh", last_name: "yeah", phone_number: "1234567890"
        valid_token = SessionToken.create user: user, last_activity_at: 4.minutes.ago

        post :create, "X-LabCompass-Auth" => valid_token.id
        response.should be_success
        response.body.should == {hello: "billy@bob.com"}.to_json
      end

      it "doesn't let you through with an expired token" do
        user = User.create email: "billy@bob.com", password: "ABsigh12"
        invalid_token = SessionToken.create user: user, last_activity_at: 30.minutes.ago

        post :create, "X-LabCompass-Auth" => invalid_token.id
        response.status.should == 401
      end
    end
  end

end
