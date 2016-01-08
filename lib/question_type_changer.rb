class QuestionTypeChanger
  class << self

    def handle_type_change(question, new_type)
      # TODO: add permission check?
      question.question_exceptions.destroy_all
      question.dependent_conditions.destroy_all
      question.option_configs.destroy_all
      question.numerical_range_config.destroy unless question.numerical_range_config.nil?
      question.text_config.destroy unless question.text_config.nil?
    end

  end
end