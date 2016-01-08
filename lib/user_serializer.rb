class UserSerializer
  class << self

    def serialize(user)
      ShallowRecordSerializer.serialize user, :email, :first_name, :last_name, :phone_number, :affiliation, :field_of_study, :create, :import, :clean, :format, :invite, :last_viewed_project, :demo_progress, :last_viewed_page
    end

  end
end
