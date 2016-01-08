class OptionConfigPresenceValidator < ActiveModel::Validator
  def validate(record)
    if ["yesno", "radio", "checkbox", "dropdown"].include?(record.question_type)
      if record.option_configs.present?
        record.option_configs = record.option_configs.select { |c| c.value && c.value.present? }
      end
      if record.option_configs.empty?
        record.errors.add(:option_configs, 'must have at least one option')
      end
    end
  end
end