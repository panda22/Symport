class FormAnswerExceptor
  class << self
    def exceptors
      @@exceptors ||= {
        "text" => AnswerExceptors::OnlyClosedExceptor,
        "date" => AnswerExceptors::DateExceptor,
        "zipcode" => AnswerExceptors::ZipcodeExceptor,
        "checkbox" => AnswerExceptors::OnlyClosedExceptor,
        "email" => AnswerExceptors::EmailExceptor,
        "radio" => AnswerExceptors::OnlyClosedExceptor,
        "dropdown" => AnswerExceptors::OnlyClosedExceptor,
        "yesno" => AnswerExceptors::OnlyClosedExceptor,
        "timeofday" => AnswerExceptors::TimeOfDayExceptor,
        "timeduration" => AnswerExceptors::OnlyClosedExceptor,
        "phonenumber" => AnswerExceptors::OnlyClosedExceptor,
        "numericalrange" => AnswerExceptors::NumericalRangeExceptor
      }
    end

    def check_exceptions(question, old_answer_record, new_answer_value, is_condition)
      exceptor = exceptors[question.question_type]
      exceptor.check_exceptions(question, old_answer_record, new_answer_value, is_condition) if exceptor
    end

    def check_all_exceptions(question, old_answer_records, new_answer_values, is_condition)
      exceptor = exceptors[question.question_type]
      exceptor.check_all_exceptions(question, old_answer_records, new_answer_values, is_condition) if exceptor
    end

  end
end
