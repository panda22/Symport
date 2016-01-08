class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_action :payload_error_handler

  before_action :header_authenticate!
  before_action :no_caching!

  protected

  def payload_error_handler
    begin
      yield
    rescue PayloadException => e
      render json: e.error, status: e.status
    rescue ActiveRecord::RecordInvalid => error
      validations = GenericRecordErrorsSerializer.validation_errors(error.record)
      render json: {validations: validations}, status: 422
    rescue ActiveRecord::RecordNotFound => error
      render json: {message: "record not found"}, status: 404
    end
  end

  def current_token
    @session_token
  end

  def current_user
    if !@current_user && @session_token
      @current_user ||= @session_token.user
    end
    @current_user
  end

  def header_session_token
    session_token request.headers["X-LabCompass-Auth"]
  end

  def form_session_token
    session_token params["X-LabCompass-Auth"]
  end

  def session_token(auth_token)
    if !@session_token
      @session_token = SessionTokenTools.find_valid_token auth_token
    end
    @session_token
  end

  def no_caching!
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
  end

  def header_authenticate!
    header_session_token
    head :unauthorized unless current_user
  end

  def form_authenticate!
    form_session_token
    head :unauthorized unless current_user
  end

end
