class FormQuestionConditionValidator < ActiveModel::Validator
  def validate(record)
    if record.depends_on.present? && record.form_question.present?
      if record.depends_on.form_structure != record.form_question.form_structure
        record.errors[:depends_on] << "Depends on question must be in same form as this question"
      elsif record.depends_on.sequence_number > record.form_question.sequence_number
        record.errors[:depends_on] << "Depends on question must be earlier in the form than this question"
      end
    end
  end
end
