class FormQuestionSerializer
  class << self
    def serialize(question)
      ShallowRecordSerializer.serialize(question, :id, :sequence_number, :variable_name,
        :personally_identifiable, :prompt, :description, :display_number).merge({
        type: question.question_type,
        config: FormQuestionConfigSerializer.serialize(question),
        exceptions: QuestionExceptionsSerializer.serialize(question),
        conditions: question.form_question_conditions.map do |cond|
          {
            dependsOn: cond.depends_on.id,
            operator: cond.operator,
            value: cond.value
          }
        end
      })
    end

    def validation_errors(question)
      {}.tap do |validations|
        question.errors.each do |prop_name, error|
          camel_name = prop_name.to_s.camelize(:lower).to_sym
          messages = validations[camel_name] ||= []
          messages << error
        end
        validations[:config] = FormQuestionConfigSerializer.validation_errors question
      end
    end
  end
end
