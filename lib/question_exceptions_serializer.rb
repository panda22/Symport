class QuestionExceptionsSerializer
  class << self
    def serialize(question, want_ids=true)
      if want_ids
        return question.question_exceptions.map do |exc|
          {
            id: exc.id,
            value: exc.value,
            label: exc.label,
            exceptionType: exc.exception_type
          }
        end
      else
        return question.question_exceptions.map do |exc|
          {
            value: exc.value,
            label: exc.label,
            exceptionType: exc.exception_type
          }
        end
      end
    end
  end
end