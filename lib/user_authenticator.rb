class UserAuthenticator
  class << self
    def find_and_authenticate(email, password, ip_addr)
      matching_user = User.find_by(email: email.try(:downcase))
      result = matching_user.try(:authenticate, password)
      AuditLogger.user_entry matching_user, result ? "sign_in" : "sign_in_failed", data: { ipAddress: ip_addr, email: email }
      result
    end
  end
end
