class AnswerValidators::ZipcodeValidator
  class << self
    def validate(question, answer)
      if !answer || answer == "" then return nil end
      unless answer == "\u200d" || /^\d{5}$/ =~ answer
        return "Please enter a valid Zip Code"
      end
      nil
    end

    def validate_all(question, answers)
      answers.map do |answer|
      	validate(question, answer)
      end
    end
  end
end