class AnswerValidators::AlwaysPassValidator
  class << self
    def validate(question, answer)
      nil
    end

    def validate_all(question, answers)
      answers.map do |answer|
      	validate(question, answer)
      end
    end
    
  end
end