class AnswerValidators::PhoneNumberValidator
  class << self
    def validate(question, answer)
      if !answer || answer == "" then return nil end
      /^(\d{3}|\(\d{3}\))-\d{3}-\d{4}(x\d+)?$/ =~ answer ? nil :
        'Please enter a valid phone number in the format ###-###-####(x#~#)'
    end

    def validate_all(question, answers)
      answers.map do |answer|
      	validate(question, answer)
      end
    end

  end
end
