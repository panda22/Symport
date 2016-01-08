class UserCreator
  class << self

    def create(json_data)
      begin
        User.create!(
          email: json_data["email"].try(:downcase).try(:strip),
          first_name: json_data["firstName"],
          last_name: json_data["lastName"],
          phone_number: json_data["phoneNumber"],
          affiliation: json_data["affiliation"],
          field_of_study: json_data["fieldOfStudy"],
          password: json_data["password"],
          password_confirmation: json_data["passwordConfirmation"] || ""
        ).tap do |user|
          AuditLogger.add user, user # user is both the current user and the record we wish to track in audit
        end
      rescue ActiveRecord::RecordNotUnique => ex
        raise PayloadException.new 422, "{\"validations\":{\"email\":[\"An account has already been registered for this e-mail address\"]}}"
      end
    end

  end
end
