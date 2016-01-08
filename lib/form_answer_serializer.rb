class FormAnswerSerializer
  class << self
    def serialize(answer, question, can_phi, wants_id=false)
      filtered = false
      if question.personally_identifiable and !can_phi
        answer_value = nil
        filtered = true
        id = nil
      elsif answer.present?
        answer_value = answer.answer
        id = answer.id
        error_msg = answer.error_msg
      end
      if wants_id
        { 
          id: id,
          answer: answer_value, 
          filtered: filtered, 
          question: FormQuestionSerializer.serialize(question),
          errorMessage: error_msg
        }
      else
        {
          answer: answer_value, 
          filtered: filtered, 
          question: FormQuestionSerializer.serialize(question),
          errorMessage: error_msg
        }
      end
    end
  end
end
