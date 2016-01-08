class AnswerValidators::EmailValidator
  class << self
    def validate(question, answer)
      EmailValidator.validate(answer)
    end

    def validate_all(question, answers)
      answers.map do |answer|
      	validate(question, answer)
      end
    end
    
  end
end