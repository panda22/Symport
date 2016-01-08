class PendingUserController < ApplicationController
  skip_before_filter :header_authenticate!, only: [:sign_in, :validate]
  def sign_in
    user_id = params[:user_id]
    id = params[:id]
    pending_user = PendingUser.find_by(:id => id, :user_id => user_id)
    user = nil
    if pending_user == nil
      raise PayloadException.access_denied "invalid invite request"
    end
    if pending_user.expires >= DateTime.now
      user = User.find(user_id)
    end
    return_json = {
        :user => (user == nil) ? nil : UserSerializer.serialize(user),
        :id => pending_user.id
    }
    render json: return_json
  end

  def validate
    user_id = params[:user_id]
    id = params[:id]
    pending_user = PendingUser.find_by(:id => id, :user_id => user_id)
    new_user = User.find(user_id)
    if pending_user == nil or new_user == nil
      raise PayloadException.access_denied "invalid invite request"
    end
    if pending_user.expires < DateTime.now
      raise PayloadException.access_denied "invalid invite request"
    end
    user_info = params[:user_info]
    new_attributes = {
        created_at: Time.now.utc.to_s,
        first_name: user_info["firstName"],
        last_name: user_info["lastName"],
        password: user_info["password"],
        password_confirmation: user_info["passwordConfirmation"],
        phone_number: user_info["phoneNumber"]
    }
    new_user.update_attributes! new_attributes
    if new_user == nil
      raise PayloadException.access_denied "invalid invite request"
    else
      PendingUser.where(:user_id => user_id).each do |temp_pending_user|
        temp_pending_user.destroy!
      end
    end

    token = SessionTokenTools.create_token new_user

    render json: {
      sessionToken: token.id,
      user: UserSerializer.serialize(new_user)
    }
  end

  def resend
    user_for_invite = User.find_by(:email => params[:user_email].try(:downcase).try(:strip))
    if user_for_invite == nil
      raise PayloadException.access_denied "pending user is not a user"
    end
    pending_user = PendingUser.find_by(:user_id => user_for_invite.id, :team_member_id => params[:teamMemberID])
    if pending_user == nil
      raise PayloadException.access_denied "pending user does not exist"
    end
    user_for_invite.update_attributes!(first_name: params[:firstName], last_name: params[:lastName])
    pending_user.message = params[:message]
    pending_user.expires = DateTime.now + 2.weeks
    pending_user.save!
    inviting_member = TeamMember.find_by(:id => params[:teamMemberID])
    team_project = Project.find_by(:id => inviting_member.project_id)
    base_url = url_for(:controller => 'index')
    valid_email = UserMailer.invite_new_user(params[:user_email], pending_user, base_url, team_project.name, current_user)
    notification_email = UserMailer.notify_new_user_invite(params[:user_email], pending_user, base_url, team_project.name, current_user)
    try_send_emails(valid_email, notification_email)
    render json: {success: true}
  end

  def get_from_team_member
    user_email = params[:email].try(:downcase).try(:strip)
    team_member_id= params[:team_member_id]
    user_for_invite = User.find_by(:email => user_email)
    if user_for_invite == nil
      raise PayloadException.access_denied "pending user is not a user"
    end
    inviting_member = TeamMember.find_by(:id => team_member_id, :user_id => current_user.id)
    if inviting_member == nil or inviting_member.administrator == false
      raise PayloadException.access_denied "inviting member does not have permission to invite"
    end
    pending_user = PendingUser.find_by(:user_id => user_for_invite.id, :team_member_id => inviting_member.id)
    if pending_user == nil
      pending_user = PendingUser.create!
      pending_user.user_id = user_for_invite.id
      pending_user.team_member_id = inviting_member.id
      pending_user.save!
    end
    render json: {
               firstName: user_for_invite.first_name,
               lastName: user_for_invite.last_name,
               message: pending_user.message,
               email: user_email,
               teamMemberID: pending_user.team_member_id
           }
  end

  def create_as_team_member
    #better to generate random uuid than save?
    #TODO verify uuid for no collisions
    first_time = false
    first_name = params[:first_name].to_s.try(:strip)
    if first_name == "" or first_name == nil
      raise PayloadException.validation_error firstName: "Please enter a first name"
    end
    inviting_member = TeamMember.find_by(:user_id => current_user.id, :project_id => params[:project_id])
    new_user_email = params[:team_member]["email"].try(:downcase).try(:strip)
    new_user = User.with_deleted.find_by(:email => new_user_email)
    last_name = params[:last_name].to_s.try(:strip)
    if new_user == nil
      new_user = User.create(
          :email => new_user_email,
          :id => SecureRandom.uuid,
          :password => SecureRandom.urlsafe_base64,
          :first_name => first_name,
          :last_name => last_name
      )
      first_time = true
    else
      new_user.deleted_at = nil
      new_user.password = SecureRandom.urlsafe_base64
      new_user.first_name = first_name
      new_user.last_name = last_name
    end

    valid_email = false
    notification_email = nil
    new_pending_user = nil
    team_project = Project.find_by(:id => params[:project_id])
    begin #catches errors in mailer and deletes created info to return db to sane state
      unless new_user.save!(:validate => false)
        raise PayloadException.access_denied "new user credentials are invalid"
      end
      new_pending_user = PendingUserUpdater.create_temp(new_user, params[:message], inviting_member)
      base_url = url_for(:controller => 'index')
      valid_email = UserMailer.invite_new_user(new_user.email, new_pending_user, base_url, team_project.name, current_user)
      notification_email = UserMailer.notify_new_user_invite(new_user.email, new_pending_user, base_url, team_project.name, current_user)
    rescue
      if new_pending_user != nil
        new_pending_user.destroy
      end
      new_user.destroy
      render json: {success: false, team_member: nil} and return
    end
    if valid_email
      team_member_data = params[:team_member]
      new_team_member = TeamMemberCreator.create(team_member_data, current_user, team_project)
      if first_time
        DemoProjectCreator.create_demo_project_for_user(new_user)  
      end
      try_send_emails(valid_email, notification_email)
      if new_team_member.save!
        render json: {success: true, team_member: TeamMemberSerializer.serialize(current_user, new_team_member)}
      else
        render json: {success: true, team_member: nil}
      end
    else
      raise PayloadException.access_denied "new user credentials are invalid"
    end

  end

  private

  def try_send_emails(user_email, notification_email)
    begin
      if user_email
        MailSender.send(user_email)
      else
        raise PayloadException.access_denied "invalid invite request"
      end
      if notification_email
        MailSender.send(notification_email)
      end
    rescue
      raise PayloadException.access_denied "invalid invite request"
    end
  end
end
