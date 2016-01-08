class UserController < ApplicationController

  skip_before_filter :header_authenticate!, only: [:create]

  def show
    render json: {
      user: UserSerializer.serialize(current_user)
    }
  end

  def update
    do_audit = true
    do_audit = false if params[:only_for_last_visited]
    user = UserUpdater.update current_user, params[:user], do_audit
    render json: {
      user: UserSerializer.serialize(user)
    }
  end

  def create
    if ENV["RAILS_ENV"] == "production"
      captcha_response = params[:captcha_response]
      url = URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=6Lc7hQwTAAAAAOOgADXk9Gm-4Y6m-e6UlhQjGOOn&response=#{captcha_response}")
      data = Net::HTTP.post_form(url, {})
      resp = JSON.parse(data.body)
      if resp["success"] != true
        raise PayloadException.new 422, "{\"validations\":{\"captcha\":[\"Please prove you're a human below\"]}}"
      end
    end
    user = UserCreator.create params[:user]
    token = SessionTokenTools.create_token user

    #DemoProjectCreator.create_demo_project_for_user(user)

    render json: {
      sessionToken: token.id,
      user: UserSerializer.serialize(user)
    }
  end

end
