class PopulateExceptionTypesForQueryParams < ActiveRecord::Migration
  def up
    QueryParam.where(:is_exception => true).each do |param|
      question = param.form_question
      unless question.nil?
        if question.question_type == "date"
          handle_date_exception(param, question)
        else
          handle_regular_exception(param, question)
        end
        param.save!
      end
    end
  end

  def down
    where_str = "is_day_exception=true or is_month_exception=true or is_year_exception=true or is_regular_exception=true"
    QueryParam.where(where_str).each do |param|
      param.is_exception = true
      param.save!
    end
  end

  def handle_date_exception(param, question)
    date_parts = param.value.split("/")
    if date_parts.length != 3
      return
    end
    day = date_parts[1]
    month = date_parts[0]
    year = date_parts[2]
    question.question_exceptions.each do |exception|
      if exception.exception_type == "date_day" and day == exception.value
        param.is_day_exception = true
      elsif exception.exception_type == "date_month" and month == exception.value
        param.is_month_exception = true
      elsif exception.exception_type == "date_year" and year == exception.value
        param.is_year_exception = true
      end
    end
  end

  def handle_regular_exception(param, question)
    question.question_exceptions.each do |exception|
      if exception.value == param.value
        param.is_regular_exception = true
      end
    end
  end
end
