class QuestionExceptionValidator 
	class << self
		def validate(record)
		    error = {}
		    if record.value == nil || record.value == ""
		    	error[:value] = "Please enter a code"
		    end
		    if record.label == nil || record.label == ""
		    	error[:label] = "Please enter a label"
		    end

		    t = record.exception_type
		    q_type = record.form_question.question_type
		    typeMismatch = false
		    case t
		    when "zipcode"
		    	if q_type != "zipcode" then typeMismatch = true end
		    when "numericalrange"
		    	if q_type != "numericalrange" then typeMismatch = true end
		    when "timeofday"
		    	if q_type != "timeofday" then typeMismatch = true end
		    when "email"
		    	if q_type != "email" then typeMismatch = true end
		    when "date_day"
		    	if q_type != "date" then typeMismatch = true end
		    when "date_month"
		    	if q_type != "date" then typeMismatch = true end
		    when "date_year"
		    	if q_type != "date" then typeMismatch = true end
		    end
		    if typeMismatch
		    	error[:exception_type] = "Exception type mismatch"
		    	return error
		    end


		    val = record.value
		    len = val.length
		    if t != "email" && t != "timeofday"
				if t == "date_year" 
					if len != 4
						error[:value] = "Please enter a code in the valid year format: YYYY"
		      		elsif val.to_i.to_s != val.to_s && val != "0000"
		      			error[:value] = "Exceptions date_year char"
					elsif (val.to_i < 2500 && val != "0000")
		      			error[:value] = "Please enter a code that could not be a valid answer to this question"
		      		end
		      	elsif t == "date_month" 
					if len != 2
						error[:value] = "Please enter a code in the valid month format: MM"
		      		elsif val.to_i.to_s != val.to_s && val != "00"
		      			error[:value] = "Please make sure that exceptions only have numbers"
					elsif (val.to_i < 13 && val != "00")
		      			error[:value] = "Please enter a code that could not be a valid answer to this question"
		      		end		
		      	elsif t == "date_day" 
					if len != 2
						error[:value] = "Please enter a code in the valid day format: DD"
		      		elsif val.to_i.to_s != val.to_s && val != "00"
		      			error[:value] = "Please make sure that exceptions only have numbers"
					elsif (val.to_i < 32 && val != "00")
		      			error[:value] = "Please enter a code that could not be a valid answer to this question"
		      		end
		      	elsif t == "numericalrange"
		      		if val.to_i.to_s != val.to_s && val != "00" && val != "000" && val != "0000" && val != "00000" && val != "000000" && val != "0000000" && val != "00000000" && val != "000000000" && val != "0000000000" 
		      			error[:value] = "Please make sure that exceptions only have numbers"
		      		end
		      		config = record.form_question.numerical_range_config
		      		if config.minimum_value && config.maximum_value
		      			min = config.minimum_value
		      			max = config.maximum_value
		      			if max < min
		      				t = min
		      				min = max
		      				max = t
		      			end
		      			if val.to_i >= min.to_i && val.to_i <= max.to_i
		      				error[:value] = "Please enter a code that is outside the numerical range for this question"
		      			end
		      		end
		      	elsif t == "zipcode"
		      		val.each_char do |char|
		      			if char.to_i.to_s != char
		      				error[:value] = "Please make sure that exceptions only have numbers"
		      			end
		      		end
		      	end
		    elsif t == "timeofday"	      		
		    	pattern = /^(\d{1,2})\:(\d{1,2})$/
	      		groups = pattern.match(val)
	      		if groups.nil? || groups[1].nil? || groups[2].nil?
	      			error[:value] = "Please enter a code in the valid format HH:MM"
	 				return error
	 			end
	 			something_is_invalid = false
	      		unless groups[1].to_i.between?(1, 12)
	      			something_is_invalid = true
	      		end
	      		unless groups[2].to_i.between?(0, 59)
	      			something_is_invalid = true
	      		end
	      		unless something_is_invalid
	      			error[:value] = "Please enter a code that could not be a valid answer to this question"
	      		end
		    end
			return error
		end
	end
end