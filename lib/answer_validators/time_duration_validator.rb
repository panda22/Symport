class AnswerValidators::TimeDurationValidator
  class << self
    def validate(question, answer)
      if !answer || answer == "" then return nil end
      pattern = /^(\d{0,3})\:(\d{0,4})\:(\d{0,6})$/
      groups = pattern.match(answer.to_s)
      if groups.nil?
        return "Invalid time duration"
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
