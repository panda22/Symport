class FormAnswerValidator
  class << self
    def validators
      @@validators ||= {
        "text" => AnswerValidators::AlwaysPassValidator,
        "date" => AnswerValidators::DateValidator,
        "zipcode" => AnswerValidators::ZipcodeValidator,
        "checkbox" => AnswerValidators::CheckboxValidator,
        "email" => AnswerValidators::EmailValidator,
        "radio" => AnswerValidators::RadioValidator,
        "dropdown" => AnswerValidators::DropdownValidator,
        "yesno" => AnswerValidators::RadioValidator,
        "timeofday" => AnswerValidators::TimeOfDayValidator,
        "timeduration" => AnswerValidators::TimeDurationValidator,
        "phonenumber" => AnswerValidators::PhoneNumberValidator,
        "numericalrange" => AnswerValidators::NumericalRangeValidator
      }
    end

    def validate(question, answer)
      if answer.present? # or required
        validator = validators[question.question_type]
        validator.validate(question, answer) if validator
      end
    end

    def validate_all(question, answers)
      validator = validators[question.question_type]
      validator.validate_all(question, answers) if validator
    end
  end
end
