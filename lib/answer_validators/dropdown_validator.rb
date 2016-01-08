class AnswerValidators::DropdownValidator
  class << self
    def validate(question, answer, option_configs=nil)
      if !answer || answer == "" then return nil end
      if option_configs == nil
        option_configs = question.option_configs
      end
      allowed_answers = option_configs.map do |o| o.value.upcase end
      unless allowed_answers.include? answer.upcase
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