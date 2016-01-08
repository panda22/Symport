class AnswerExceptors::OnlyClosedExceptor
  class << self
    def check_exceptions(question, old_answer_record, new_answer_value, is_condition)
      if new_answer_value == "\u200d"
        old_answer_record.closed = true
        return true
      end
      old_answer_record.closed = false
      return false
    end

    def check_all_exceptions(question, old_answer_records, new_answer_values, is_condition)
      i = 0
      results = []
      while(i < old_answer_records.length)
        results[i] = check_exceptions(question, old_answer_records[i], new_answer_values[i], is_condition)
        i = i + 1
      end
      results
    end

  end
end