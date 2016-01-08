class PasswordResetsController < ApplicationController
  #before_action :set_password_reset, only: [:show, :edit, :update, :destroy]
  skip_before_filter :header_authenticate!, only: [:create, :index, :update]
  # GET /password_resets
  #used to verify password reset and return user if verified
  def index
    cur_user = nil
    success = false
    if PasswordResetValidator.is_valid_reset?(params[:rid], params[:uid])
      cur_user = User.find(params[:uid])
      success = true
    end
    render json: {
      result: success,
      user: cur_user ? UserSerializer.serialize(cur_user) : nil
    }
  end

  def update
    result = false
    if PasswordResetValidator.is_valid_reset?(params[:rid], params[:uid])
      new_attributes = {}
      new_attributes[:password] = params[:user]["password"]
      new_attributes[:password_confirmation] = params[:user]["passwordConfirmation"]
      user_id = params[:uid]
      user = User.find(user_id)
      if user != nil and user.update_attributes! new_attributes
        PasswordReset.where(:user_id => user_id).each do |reset|
          reset.destroy!
        end
        PendingUser.where(:user_id => user_id).each do |pending_user|
          pending_user.destroy!
        end
        result = true
      end
    end
    render json: {result: result}
  end

  # GET /password_resets/new
  def new
    @password_reset = PasswordReset.new
  end

  # POST /password_resets
  def create
    user = User.find_by(:email => params[:user_email])
    success = false
    if user != nil
      @password_reset = PasswordReset.new
      @password_reset.user_id = user.id
      if @password_reset.save
        success = true
        base_url = url_for(:controller => 'index')
        MailSender.send(UserMailer.password_reset(user, @password_reset, base_url))
      end
    end
    render json: {result: success}
  end

  # DELETE /password_resets/1
  def destroy
    @password_reset.destroy
    redirect_to password_resets_url, notice: 'Password reset was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_password_reset
      @password_reset = PasswordReset.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def password_reset_params
      params.require(:password_reset).permit(:created_at, :user_id)
    end
end
