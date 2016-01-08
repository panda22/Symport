class FormQuestionConditionsCreator
  class << self
    def create(data)
      question_conditions = data.map do |cond_data|
        FormQuestionCondition.new depends_on_id: cond_data[:dependsOn], 
          operator: cond_data[:operator], value: cond_data[:value]
      end
      QuestionConditionsValidator.validate(question_conditions)
      question_conditions
    end
  end
end