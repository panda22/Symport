class User < ActiveRecord::Base
  acts_as_paranoid

  has_many :team_members
  has_many :projects, through: :team_members
  has_many :form_structure_permissions, through: :team_members

  has_many :session_tokens

  has_secure_password

  validates :password, 
    presence: { message: "Please enter a valid password" }, 
    length: { minimum: 8, message: "Please enter a password matching conditions to the right" },     
    format: { with: /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s)[0-9a-zA-Z!@#$%^&*()?.]*\z/, message: "Please enter a password matching conditions to the right", unless: lambda { password.length < 8}}, 
    if: :password_digest_changed? 

  validates :email, presence: { message: "Email addresses should be in the format example@xyz.com" }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create, message: "Email addresses should be in the format example@xyz.com", unless: lambda { email == nil }}
  validates :first_name, presence: { message: "Please tell us your first name" }
  validates :last_name, presence: { message: "Please tell us your last name" }
  #validates :phone_number, presence: { message: "Please tell us your phone number" }

  validates :demo_progress, :inclusion => {:in => [0,1,2,3,4,5,6]}

  after_create :send_email_notification

  def full_name
    first_name + " " + last_name
  end

  private
  def send_email_notification
    if ENV["RAILS_ENV"] == "production"
      notification_mail = UserMailer.notify_new_user_create(self)
      welcome_mail = UserMailer.welcome_new_user(self)
      MailSender.send(notification_mail)
      MailSender.send(welcome_mail)
    end
  end

end
