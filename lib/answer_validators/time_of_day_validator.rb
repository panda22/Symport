class AnswerValidators::TimeOfDayValidator
  class << self
    def validate(question, answer)
      if !answer || answer == "" then return nil end
      pattern = /^(\d{1,2})\:(\d{1,2})\ (AM|PM|am|pm)$/
      groups = pattern.match(answer)
      if groups.nil? or invalid?(groups[1].to_i, groups[2].to_i, groups[3].downcase)
        return "Please enter a valid time of day in the format HH:MM AM/PM"
      end
      nil
    end

    def validate_all(question, answers)
      answers.map do |answer|
        validate(question, answer)
      end
    end

    def invalid?(hour, minutes, ampm)
      invalid = false
      return invalid = true unless hour.between?(1, 12) 
      return invalid = true unless minutes.between?(0, 59)
      return invalid = true unless ampm.eql? "am" or ampm.eql? "pm"
      return invalid
    end
  end
end
