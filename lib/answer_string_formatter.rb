class AnswerStringFormatter
  class << self
    def format(answer, type, empty_code, blocked_code)
      if answer == nil or answer == ""
        return empty_code
      elsif answer == "\u200D"
        return blocked_code
      #elsif type == "timeduration"
      #  return  AnswerStringFormatter.convert_time_duration_int_to_string(answer.to_i, empty_code, blocked_code)
      else
        return answer
      end
    end
  end
end