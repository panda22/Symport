class OtherQuestionTypeGridHandler
  class << self
		def add_other_question_to_form_hash(question, question_to_form_hash, index)
			type = question.question_type
			if type == "checkbox" or type == "radio"
				question.option_configs.reverse_each do |config|
					if config.other_option == true
						val = (config.other_variable_name == "" or config.other_variable_name == nil) ? config.value : config.other_variable_name
						form = question.form_structure
						question_to_form_hash[val] = {
								name: form.name,
								index: index
						}
					end
				end
			end
		end

    def get_and_push_other_questions (question, heading, num_instances=1, instance_number=0)
			type = question.question_type
			new_columns = []
			if type == "checkbox" or type == "radio"
				question.option_configs.reverse_each do |config|
					if config.other_option == true
						new_columns.push(config)
						val = (config.other_variable_name == "" or config.other_variable_name == nil) ? config.value : config.other_variable_name
						val = (num_instances <= 1) ? val : "#{val}_#{instance_number+1}"
						heading.push({
								value: val,
								type: "text"
							})
						#if question_to_form_hash != nil
						#	question_to_form_hash[val] = question_to_form_hash[question.variable_name].clone
						#end
					end
				end
			end
			return new_columns
		end

		def push_other_question_answers(other_columns, answer, index, grid, empty_code = "", blocked_code = "\u200D", use_codes=false)
			other_columns.each do |config|
				target = (use_codes) ? config.code : config.value
				other_val = get_other_question_answer_val(answer, target)
				if other_val == "" or other_val == nil
					other_val = empty_code
				elsif other_val == "\u200D"
					other_val = blocked_code
				end
				grid[index].push(value: other_val, exception: false)
			end
		end

		private
		def get_other_question_answer_val(answer, target_val)
			if answer == nil
				return "\u200D"
			end
			answer.split("\u200C").each do |answer_part|
				if answer_part.split("\u200A").length == 2
					other_var_name, other_val = answer_part.split("\u200A")
					if other_var_name == target_val
						return other_val
					end
				elsif answer_part.include?("\u200A")
					return ""
				end
			end
			return "\u200D"
		end
  end
end