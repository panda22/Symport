class AnswerExceptors::DateExceptor
  class << self
    
    def check_all_exceptions(question, old_answer_records, new_answer_values, is_condition)
      exceptions = {}
      exceptions[:day_exceptions] = question.question_exceptions.where(exception_type: "date_day")
      exceptions[:month_exceptions] = question.question_exceptions.where(exception_type: "date_month")
      exceptions[:year_exceptions] = question.question_exceptions.where(exception_type: "date_year")
      i = 0
      results = []
      while(i < old_answer_records.length)
        results[i] = check_exceptions(question, old_answer_records[i], new_answer_values[i], is_condition, exceptions)
        i = i + 1
      end
      results
    end

    def check_exceptions(question, old_answer_record, new_answer_value, is_condition, exceptions=nil)

      old_answer_record.year_exception = old_answer_record.day_exception = old_answer_record.month_exception = nil
      old_answer_record.closed = false
      
      if new_answer_value == "\u200d"
        old_answer_record.closed = true
        return true
      end
      month_exc = day_exc = year_exc = nil
      
      new_answer_value_copy = new_answer_value.dup

      if new_answer_value_copy.slice(0,2) == "##" && is_condition
      	new_answer_value_copy[0] = "0"
      	new_answer_value_copy[1] = "1"	  	
      	month_exc = true
      end
      if new_answer_value_copy.slice(3,2) == "##" && is_condition
      	new_answer_value_copy[3] = "0"
      	new_answer_value_copy[4] = "1"	  	
      	day_exc = true
      end
      if new_answer_value_copy.slice(6,4) == "####" && is_condition
      	new_answer_value_copy[6] = "2"
      	new_answer_value_copy[7] = "0"	  	
      	new_answer_value_copy[8] = "0"	  	
      	new_answer_value_copy[9] = "0"	  	
      	year_exc = true
      end      

      pattern = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/
      groups = pattern.match(new_answer_value_copy)

      if groups.nil? || groups[1].nil? || groups[2].nil? || groups[3].nil?
        return false
      end

      try_year = year = groups[3]
      try_day = day = groups[2]
      try_month = month = groups[1]
    
      day_exceptions = []
      if exceptions == nil
        day_exceptions = question.question_exceptions.where(exception_type: "date_day")
      else
        day_exceptions = exceptions[:day_exceptions]
      end
      day_exceptions.each do |exc|
        if exc.value == day
          day_exc = exc.id
          try_day = "01"
        end
      end

      month_exceptions = []
      if exceptions == nil
        month_exceptions = question.question_exceptions.where(exception_type: "date_month")
      else
        month_exceptions = exceptions[:month_exceptions]
      end
      month_exceptions.each do |exc|
        if exc.value == month
          month_exc = exc.id
          try_month = "01"
        end
      end

      year_exceptions = []
      if exceptions == nil
        year_exceptions = question.question_exceptions.where(exception_type: "date_year")
      else
        year_exceptions = exceptions[:year_exceptions]
      end
      year_exceptions.each do |exc|
        if exc.value == year
          year_exc = exc.id
          try_year = "2000"
        end
      end

      if Date.valid_date?(try_year.to_i, try_month.to_i, try_day.to_i) && (day_exc || month_exc || year_exc)
        old_answer_record.year_exception = year_exc
        old_answer_record.day_exception = day_exc
        old_answer_record.month_exception = month_exc
        return true
      else
        return false
      end
    end
  end
end