class PasswordResetValidator
  class << self
    def is_valid_reset? (rid, uid)
      expiration_hours = 2
      pass_reset = PasswordReset.where(:id => rid, :user_id => uid).first()
      if pass_reset == nil
        return false
      end
      hours_since_request= (DateTime.current().to_i - pass_reset["created_at"].to_i) / 3600
      if hours_since_request >= expiration_hours
        pass_reset.destroy
        return false
      end
      return true
    end
  end
end