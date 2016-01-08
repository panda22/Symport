class AnswerValidators::CheckboxValidator
  class << self
    def validate(question, answer, option_configs=nil)
      if !answer || answer == "" then return nil end
      if option_configs == nil
        option_configs = question.option_configs
      end
      error = "Invalid options:"
      answer_parts = (answer || "").split("\u200c")
      all_answers_good = true
      
      answer_parts.each do |answer_part|
        validated = false
        option_configs.each do |o|
          if o.other_option && answer_part.index("\u200a")
            if answer_part.slice(0, answer_part.index("\u200a")).strip.upcase == o.value.upcase
              validated = true
            end
          else
            if answer_part.strip.upcase == o.value.upcase
              validated = true
            end
          end   
        end 
        if !validated
          all_answers_good = false
          error += " " + answer_part
        end
      end

      if error == "Invalid options:"
        return nil
      else
        return error
      end
    end

    def validate_all(question, answers)
      option_configs = question.option_configs
      answers.map do |answer|
        validate(question, answer, option_configs)
      end
    end

  end
end