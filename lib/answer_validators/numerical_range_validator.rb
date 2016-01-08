class AnswerValidators::NumericalRangeValidator
  class << self
    def validate(question, answer, range=nil)
      
      if !answer || answer == "" then return nil end
      if range == nil
        range = question.numerical_range_config
      end

      value = answer.to_s
      f_value = answer.to_f

      precision = range.precision.to_i


      unless /\A[-+]?[0-9]*\.?[0-9]+\Z/ =~ answer
        unless answer[answer.length-1] == "."
          return "Please enter a valid number"
        end
      end


      if range.minimum_value == nil && range.maximum_value == nil
        if lacks_precision? value, precision
          return "Your value must have at least #{precision} decimal places"
        elsif should_be_whole_number? value, precision
          return "Your value must be a whole number"
        else
          return nil
        end
      end

      if range.minimum_value == nil
        max = range.maximum_value
        if f_value > max
          return "#{value} is greater than #{max}, please enter a number in the specified range"
        elsif lacks_precision? value, precision
          return "Your value must have at least #{precision} decimal places"
        elsif should_be_whole_number? value, precision
          return "Your value must be a whole number"
        else
          return nil
        end
      end

      if range.maximum_value == nil
        min = range.minimum_value
        if f_value < min
          return "#{value} is less than #{min}, please enter a number in the specified range"
        elsif lacks_precision? value, precision
          return "Your value must have at least #{precision} decimal places"
        elsif should_be_whole_number? value, precision
          return "Your value must be a whole number"
        else
          return nil
        end
      end

      
      range = [range.minimum_value , range.maximum_value]
      min = range.min
      max = range.max

      if f_value > max
        "#{value} is greater than #{max}, please enter a number in the specified range"
      elsif f_value < min
        "#{value} is less than #{min}, please enter a number in the specified range"
      elsif lacks_precision? value, precision
        "Your value must have at least #{precision} decimal places"
      elsif should_be_whole_number? value, precision
        "Your value must be a whole number"
      else
        nil
      end
    end

    def validate_all(question, answers)
      range = question.numerical_range_config
      answers.map do |answer|
        validate(question, answer, range)
      end
    end

    private

    def lacks_precision?(value, precision)
      if precision == 6
        return false
      end
      value_precision = (value.split(".")[1] || "").length
      value_precision < precision
    end

    def should_be_whole_number?(value, precision)
      if precision == 0
        value.split(".").length != 1
      end
    end

    def precision_to_s(precision)
      case precision
      when '0'
        "1"
      when '1'
        "0.1"
      when '2'
        "0.01"
      when '3'
        "0.001"
      when '4'
        "0.0001"
      when '5'
        "0.00001"
      when '6'
        "Any number of decimal places"
      else "6"
      end
    end
  end

end
