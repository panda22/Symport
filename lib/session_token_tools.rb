class SessionTokenTools
  class << self
    def create_token(user)
      if user.present?
        SessionToken.create! last_activity_at: Time.now, user: user
      end
    end

    def find_valid_token(token_id, note_activity = true)
      begin
        token = SessionToken.find token_id
      rescue
      end
      if token && SessionTokenTools.token_valid?(token)
        if note_activity == "true" || note_activity == true
          token.update_attributes(last_activity_at: Time.now)
        end
        token
      end
    end

    def token_valid?(token)
      token.last_activity_at >= 15.minutes.ago
    end

    def destroy_token(token)
      begin
        token.delete!
        true
      rescue
        false
      end
    end
  end
end