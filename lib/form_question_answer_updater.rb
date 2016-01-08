class FormQuestionAnswerUpdater
  class << self
    def update(user, question, response_record, new_answers)
      answer_record = FormAnswerProcessor.find_or_create_answer(question, response_record)

      answer_index = new_answers.index do |answer| answer[:question] == question.id end

      answer_data = answer_index ? new_answers[answer_index] : {}

      error = FormAnswerProcessor.validate_and_save(user, question, answer_record, answer_data[:answer])
      if error
        {answer_index => { answer: error }}
      else 
        {}
      end
    end

    def validate(user, question, new_answers)
      if new_answers == nil
        return {}
      end
      answer_record = FormAnswerProcessor.get_new_answer(question)
      answer_index = new_answers.index do |answer| answer[:question] == question.id end
      answer_data = answer_index ? new_answers[answer_index] : {}

      error = FormAnswerProcessor.validate(user, question, answer_record, answer_data[:answer])
      if error
        {answer_index => { answer: error }}
      else 
        {}
      end
    end

  end
end
