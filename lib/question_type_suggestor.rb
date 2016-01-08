class QuestionTypeSuggestor
  class << self
    def suggest_question_type(values)
      num_vals = values.length
      num_empty = values.select do |val|
        val == ""
      end.count

      if num_empty >= values.length
        return ["text"]
      end

      if are_email?(values,num_empty) > 0.7 then return ["email"] end
      
      if are_date?(values,num_empty) > 0.6 then return ["date"] end
      
      if are_time_of_day?(values,num_empty) > 0.6 then return ["timeofday"] end
      
      if are_time_duration?(values,num_empty) > 0.7 then return ["timeduration"] end
      
      if are_phone?(values,num_empty) > 0.7 then return ["phonenumber"] end

      yes_no = are_yes_no?(values,num_empty)
      if yes_no > 0.99999 && yes_no < 1.00001
        return ["yesno", {
            selections: [
              {value: 'Yes', code: 1, otherOption: false, otherVariableName: nil},
              {value: 'No', code: 2, otherOption: false, otherVariableName: nil}
            ]
          }
        ]
      end
      prob_nums = false
      numeric = are_numeric?(values,num_empty)
      if numeric[0] > 0.75
        if numeric[1] > 0.90
          return ["zipcode"]
        end ##MOVE TO BEFORE MC CHECK && MAKE SURE DISTINCE VALUES > 10
        if values.uniq.length > 7
          return ["numericalrange"]
        else
          prob_nums = true
        end
      end 

      if num_vals - num_empty < 20
        return ["text"]
      end

      num_delims_found = 0.0
      ['|','/',':',';','-','.','&',','].each do |char|
        values.each do |val|
          if val.index(char)
            num_delims_found += 1
          end
        end
        if num_delims_found/(num_vals-num_empty) > 0.4
          suggested_checkbox_options = []
          in_big_checkbox_buckets = 0.0
          checkbox_bucket_threshold = (num_vals-num_empty) * 0.15
          checkbox_options?(values,char).each do |o|
            if o[1] > checkbox_bucket_threshold
              in_big_checkbox_buckets += o[1]
              suggested_checkbox_options.push o[0]
            end
          end
          if in_big_checkbox_buckets/(num_vals-num_empty) > 0.7
            config = {selections: []}
            i = 0
            suggested_checkbox_options.each do |val|
              i = i + 1
              config[:selections].push({
                value: val,
                code: i,
                otherOption: false,
                otherVariableName: nil
              })
            end
            return ["checkbox", config, (values.map do |a| a.split(char).join("\u200c") end)]
          end
        end
      end

      options = options?(values)

      suggested_radio_options = []
      in_big_radio_buckets = 0.0
      radio_bucket_threshold = (num_vals-num_empty) * 0.10
      options.each do |o|
        if o[1] > radio_bucket_threshold
          in_big_radio_buckets += o[1]
          suggested_radio_options.push o[0]
        end
      end
      if in_big_radio_buckets/(num_vals-num_empty) > 0.7
        config = {selections: []}
        i = 0
        suggested_radio_options.each do |val|
          i = i + 1
          config[:selections].push({
            value: val,
            code: i,
            otherOption: false,
            otherVariableName: nil
          })
        end
        if suggested_radio_options.count > 6
          return ["dropdown", config]
        end
        return ["radio", config]
      end


      if prob_nums              ## if not many distinct values, 
        return ["numericalrange"] ## let MC check happen before assuming range
      end

      return ["text"]

    end
    def checkbox_options?(values, delim)
      options = {}
      values.each do |vv|
        vals = vv.split(delim)
        vals.each do |v|
          val = v.strip.downcase
          val[0] = val.first.capitalize
          if options[val]
            options[val] += 1
          elsif val != ""
            options[val] = 1
          end
        end
      end
      return options
    end
    def options?(values)
      options = {}
      values.each do |v|
        val = v.strip.downcase
        val[0] = val.first.capitalize
        if options[val]
          options[val] += 1
        elsif val != ""
          options[val] = 1
        end
      end
      return options
    end
    def are_yes_no?(values,num_empty)
      matched = total = 0.0
      values.each do |v|
        val = v.upcase
        if val == "YES" || val == "NO" || val == "N" || val == "Y"
          matched += 1
        end
        total += 1
      end
      return matched/(total-num_empty)
    end
    def are_numeric?(values,num_empty)
      matched = total = five_digits = 0.0
      values.each do |val|
	      if val =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
          if val.length == 5
          	five_digits += 1
          end
          matched += 1
        end
        total += 1
      end
      return [matched/(total-num_empty), five_digits/matched]
    end
    def are_email?(values,num_empty)
      res = AnswerValidators::EmailValidator.validate_all(nil, values)
      matched = total = 0.0
      res.each do |r|
        if !r
          matched += 1
        end
        total += 1
      end
      return (matched-num_empty)/(total-num_empty)
    end
    def are_date?(values,num_empty)
      res = AnswerValidators::DateValidator.validate_all(nil, values)
      matched = total = 0.0
      res.each do |r|
        if !r
          matched += 1
        end
        total += 1
      end
      return (matched-num_empty)/(total-num_empty)
    end
    def are_time_of_day?(values,num_empty)
      res = AnswerValidators::TimeOfDayValidator.validate_all(nil, values)
      matched = total = 0.0
      res.each do |r|
        if !r
          matched += 1
        end
        total += 1
      end
      return (matched-num_empty)/(total-num_empty)
    end
    def are_time_duration?(values,num_empty)
      res = AnswerValidators::TimeDurationValidator.validate_all(nil, values)
      matched = total = 0.0
      res.each do |r|
        if !r
          matched += 1
        end
        total += 1
      end
      return (matched-num_empty)/(total-num_empty)
    end
    def are_phone?(values,num_empty)
      res = AnswerValidators::PhoneNumberValidator.validate_all(nil, values)
      matched = total = 0.0
      res.each do |r|
        if !r
          matched += 1
        end
        total += 1
      end
      return (matched-num_empty)/(total-num_empty)
    end
  end
end