class AnswerValidators::DateValidator
  class << self
    def validate(question, answer)
      if !answer || answer == "" then return nil end
      pattern = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/
      groups = pattern.match(answer)
      if groups.nil? 
        return "Please enter a valid date in the format mm/dd/yyyy"
      end
      try_year = groups[3].to_i

      try_day = groups[2].to_i

      try_month = groups[1].to_i

      if !Date.valid_date?(try_year, try_month, try_day) || try_year > 2500
        return "Please enter a valid date in the format mm/dd/yyyy"
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