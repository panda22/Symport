class FormAnswerProcessor
  class << self

    def find_or_create_answer(question, response_record)
      answer = response_record.form_answers.find do |answer|
        answer.form_question.present? && answer.form_question.id == question.id
      end
      if answer.nil?
        answer = FormRecordCreator.create_answer question
        response_record.form_answers << answer
      end
      answer
    end

    def get_new_answer(question)
      answer = FormRecordCreator.new_answer question
      answer
    end    

    def validate_and_save(user, question, answer_record, answer_value, reset_ignore=false)
      error = false
      exception = FormAnswerExceptor.check_exceptions(question, answer_record, answer_value, false)
      if !exception
        error = FormAnswerValidator.validate(question, answer_value)
      end
      AuditLogger.surround_edit user, answer_record do
        if answer_record.answer != answer_value or reset_ignore
          answer_record.ignore_error = false
        end
        answer_record.answer = answer_value
        if exception
          error = nil
        end
        answer_record.error_msg = error
        answer_record.save!
      end
      error
    end

    def validate_and_save_all(user, question, answer_records, answer_values, reset_ignore=false)
      exceptions = FormAnswerExceptor.check_all_exceptions(question, answer_records, answer_values, false)
      errors = FormAnswerValidator.validate_all(question, answer_values)
      new_answers_data = []
      old_ids = []
      i = 0
      while(i < answer_records.length)
        if answer_records[i].answer != answer_values[i] or reset_ignore
          answer_records[i].ignore_error = false
        end
        answer_records[i].answer = answer_values[i]
        if exceptions[i]
          errors[i] = nil
        end
        answer_records[i].error_msg = errors[i]
        a = answer_records[i]
        new_string = "'#{a.form_question_id}', '#{a.form_response_id}', '#{a.created_at}', '#{Time.now.utc.to_s}', #{FormAnswer.sanitize(a.error_msg)}, '#{a.ignore_error}', '#{a.closed}', '#{a.regular_exception}',  '#{a.day_exception}', '#{a.month_exception}', '#{a.year_exception}', "
        new_string.gsub!("''", "NULL")
        new_string += FormAnswer.sanitize(a.answer) 
        new_answers_data.push(new_string)
        if a.id && a.id != ""
          old_ids.push(a.id)
        end
        i = i + 1
      end
      FormAnswer.delete(old_ids)
      unless new_answers_data.length == 0
        sql = "INSERT INTO form_answers (form_question_id, form_response_id, created_at, updated_at, error_msg, ignore_error, closed, regular_exception, day_exception, month_exception, year_exception, answer) VALUES (#{new_answers_data.join("), (")})"
        FormAnswer.connection.execute sql
      end
      errors
    end

    def validate(user, question, answer_record, answer_value)
      error = false
      exception = FormAnswerExceptor.check_exceptions(question, answer_record, answer_value, false)
      if !exception
        error = FormAnswerValidator.validate(question, answer_value)
      end
      error
    end

  end
end
