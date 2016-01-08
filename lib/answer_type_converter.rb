class AnswerTypeConverter
	class << self
		
		def convert(answer_str, type_str)
			begin
				if answer_str == nil or type_str == nil or answer_str == "" or type_str == ""
					return nil
				end
				case type_str
				when "numericalrange"
					if (Float(answer_str) != nil rescue false)
						return Float(answer_str)
					else
						return nil
					end
				when "timeduration"
					begin
						return nil if answer_str == ""
						pattern = /^(\d{0,3})\:(\d{0,4})\:(\d{0,6})/
						groups = pattern.match(answer_str)
						return nil if groups.nil?
						groups[1].to_i * 60 * 60 + groups[2].to_i * 60 + groups[3].to_i
					rescue
						nil
					end
				when "timeofday"
					return nil if answer_str == ""
					return DateTime.parse(answer_str) rescue answer_str
				when "date"
					pattern = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/
					groups = pattern.match(answer_str)
					days = groups[2]
					months = groups[1]
					years = groups[3]
					new_date = months + "/" + days + "/" + years
					return Date.strptime(new_date, "%m/%d/%Y") rescue answer_str
				when "phonenumber"
					if answer_str == "()--"
						return nil
					else
						return answer_str
					end
				else
					return answer_str
				end
			rescue
				return nil
			end
		end

	end
end