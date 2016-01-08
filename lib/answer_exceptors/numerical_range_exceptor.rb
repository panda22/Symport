class AnswerExceptors::NumericalRangeExceptor
  class << self
    def check_exceptions(question, old_answer_record, new_answer_value, is_condition)
      AnswerExceptors::RegularExceptor.check_exceptions(question, old_answer_record, new_answer_value, is_condition)
    end
    def check_all_exceptions(question, old_answer_records, new_answer_values, is_condition)
      AnswerExceptors::RegularExceptor.check_all_exceptions(question, old_answer_records, new_answer_values, is_condition)
    end
  end
end