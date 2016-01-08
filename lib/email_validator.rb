class EmailValidator
  class << self
    def validate(email)
      if !email || email == "" then return nil end
      if email == "\u200d" then return nil end
      pattern = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
      unless pattern =~ email
        return "Please enter a valid email in the format example@xyz.com"
      end
    end
  end
end