class SessionController < ApplicationController

  skip_before_action :header_authenticate!, only: [:create, :valid]

  def create
    ip_addr = request.remote_ip
    user = UserAuthenticator.find_and_authenticate(params[:user][:email], params[:user][:password], ip_addr)
    if user.present?
      session_token = SessionTokenTools.create_token(user)
      render json: { sessionToken: session_token.id, user: UserSerializer.serialize(user), success: true }
    else
      render json: { success: false }, status: 401
    end
  end

  def activity
    render json: {}
  end

  def valid
    active = SessionTokenTools.find_valid_token request.headers["X-LabCompass-Auth"], params[:validate]
    
    dying = false
    if active && active.last_activity_at >= 15.minutes.ago && active.last_activity_at <= 10.minutes.ago
      dying = true
    end
    
    render json: {active: !!active, dying: dying}
  end

  def destroy
    token = current_token
    result = SessionTokenTools.destroy_token(token)
    # TODO: add third parameter to AuditLogger function if needed
    AuditLogger.user_entry current_user, "sign_out"
    render json: {success: result}
  end
end