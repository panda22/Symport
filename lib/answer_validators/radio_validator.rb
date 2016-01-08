class AnswerValidators::RadioValidator
  class << self
    def validate(question, answer, option_configs=nil)
      if !answer || answer == "" then return nil end
      if option_configs == nil
        option_configs = question.option_configs
      end
   	  validated = false
      option_configs.each do |o|
        if o.other_option && answer.index("\u200a") != nil
          if answer.slice(0, answer.index("\u200a")).strip.upcase == o.value.upcase
          	validated = true
          end
        else
          if answer.strip.upcase == o.value.upcase
          	validated = true
          end
        end		
      end
 
      unless validated
        "Invalid options: #{answer}"
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