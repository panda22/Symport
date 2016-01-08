class FormQuestionConfigSerializer
  class << self
    def serialize(question)
      case question.question_type
      when 'text'
        if question.text_config.nil?
          raise PayloadException.new 404, "why?"
        end
        { size: question.text_config.size }
      when 'numericalrange'
        {
          minValue: question.numerical_range_config.minimum_value,
          maxValue: question.numerical_range_config.maximum_value,
          precision: question.numerical_range_config.precision
        }
      when 'checkbox', 'radio', 'yesno', "dropdown"
        {
          selections: question.option_configs.sort_by(&:index).map do |c|
            {
              value: c.value, 
              id: c.id,
              otherOption: c.other_option,
              otherVariableName: c.other_variable_name,
              code: c.code
            }
          end
        }
      else
        {}
      end
    end

    def validation_errors(question)
      validations = {}

      if question.numerical_range_config.present?
        question.numerical_range_config.errors.each do |prop_name, error|
          key = case prop_name.to_s
          when 'minimum_value'
            'minValue'
          when 'maximum_value'
            'maxValue'
          else
            prop_name
          end
          validations[key] ||= []
          validations[key] << error
        end
      end
      if question.text_config.present?
        question.text_config.errors.each do |prop_name, error|
          validations[prop_name] ||= []
          validations[prop_name] << error
        end
      end
      question.option_configs.each do |option|
        option.errors.each do |prop_name, error|
          selections = validations[:selections] ||= {}
          errors = selections[option.index] ||= []
          errors << error
        end
      end

      validations
    end
  end
end
