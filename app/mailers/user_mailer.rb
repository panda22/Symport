class UserMailer < ActionMailer::Base
  default from: "symport@mntnlabs.com"

  def password_reset(user, reset, base_url)
  	@user = user
  	@reset = reset
  	@url = "#{base_url}#/account/reset-password/#{@user.id}/#{@reset.id}"
  	mail(to: @user.email, subject: 'Symport Password Assistance')
	end

	def invite_new_user(email, pending_user, base_url, project_name="Symport", inviting_user=nil)
		default_user = Object.new
		default_user.define_singleton_method(:first_name) do
			"System"
		end
		default_user.define_singleton_method(:last_name) do
			"Administrator"
		end
		@project_name = project_name
		@pending_user = pending_user
		@inviting_user = (inviting_user == nil) ? default_user : inviting_user
		@full_message = pending_user.message
		@url = "#{base_url}#/account/user-invite/#{@pending_user.user_id}/#{@pending_user.id}"
		mail(to: email, subject: "#{@inviting_user.first_name} #{@inviting_user.last_name} has invited you to #{project_name}")
	end

	def notify_new_user_invite(email, pending_user, base_url, project_name="Symport", inviting_user=nil)
		default_user = Object.new
		default_user.define_singleton_method(:first_name) do
			"System"
		end
		default_user.define_singleton_method(:last_name) do
			"Administrator"
		end
		@project_name = project_name
		@pending_user = pending_user
		@inviting_email = (inviting_user == nil) ? "Internal" : inviting_user.email
		@inviting_user = (inviting_user == nil) ? default_user : inviting_user
		@full_message = pending_user.message
		@url = "#{base_url}#/account/user-invite/#{@pending_user.user_id}/#{@pending_user.id}"
		@received_address = email
		notification_address = "accounts@mntnlabs.com"
		mail(to: notification_address, subject: "new user invited")
	end

	def notify_new_user_create(user)
		@user = user
		notification_address = "accounts@mntnlabs.com"
		mail(to: notification_address, subject: "new user created")
	end

	def welcome_new_user(user)
		@first_name = user.first_name
		mail(to: user.email, subject: "You’re in! (Plus a quick question)")
	end

end
