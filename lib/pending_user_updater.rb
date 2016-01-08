class PendingUserUpdater
  class << self
    def create_temp(user, message="", team_member=nil)
      #TODO check for existing team member by email
      #TODO verify uuid for no collisions
      return_user = PendingUser.create(
          :expires => get_new_expiration_date,
          :message => message,
          :team_member_id => (team_member == nil) ? nil : team_member.id,
          :user_id => user.id,
          :id => SecureRandom.uuid
      )
      unless return_user.save!(:validation => false)
        raise PayloadException.email "pending user credentials are invalid"
      end

      return return_user
    end

    private
    def get_new_expiration_date
      return DateTime.now + 2.weeks
    end
  end
end