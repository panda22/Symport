class QuestionConditionsValidator
  class << self
    def validate(form_question_conditions = [])
      errors = {}
      form_question_conditions.each_with_index do |question_condition, condition_index|
        parent_question = FormQuestion.find_by(id: question_condition.depends_on_id)
        if parent_question.present?
          fake_answer_record = FormAnswer.new({form_question_id: parent_question.id})
          error = false
          equal_not_equal = question_condition.operator == "<>" || question_condition.operator == "="
          exception = FormAnswerExceptor.check_exceptions(parent_question, fake_answer_record, question_condition.value, true)
          if exception && !equal_not_equal
            errors[condition_index] = {value: "You may not set conditions to be greater than or less than a missing, unknown or skipped code"}
          elsif !exception
            error = FormAnswerValidator.validate(parent_question, question_condition.value)
            errors[condition_index] =  { value: error } if error.present?
          end
        else
          errors[condition_index] = { dependsOn: "Question does not exist" }
        end
      end
      raise PayloadException.new 422, { validations: { conditions: errors } } if errors.present?
    end
  end
end
