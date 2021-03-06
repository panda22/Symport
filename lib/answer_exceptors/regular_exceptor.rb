class AnswerExceptors::RegularExceptor
  class << self
    def check_exceptions(question, old_answer_record, new_answer_value, is_condition, exceptions=nil)
      old_answer_record.regular_exception = nil
      old_answer_record.closed = false
      
      if new_answer_value == "\u200d"
        old_answer_record.closed = true
        return true
      end


      if exceptions == nil
        exceptions = question.question_exceptions
      end
      found_exc = false
      exceptions.each do |exc|
      	if new_answer_value == exc.value
      		old_answer_record.regular_exception = exc.id
      		return true
      	end
      end
      return false
    end

    def check_all_exceptions(question, old_answer_records, new_answer_values, is_condition)
      exceptions = question.question_exceptions
      i = 0
      results = []
      while(i < old_answer_records.length)
        results[i] = check_exceptions(question, old_answer_records[i], new_answer_values[i], is_condition, exceptions)
        i = i + 1
      end
      results
    end

  end
end