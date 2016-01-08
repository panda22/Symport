class FormQuestionUpdater
  class << self
    def update(user, question, structure, data, prev_question_id=nil)
      if !Permissions.user_can_edit_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have permission to update questions on this form"
      end
      keys = {
        prompt: nil,
        description: nil,
        variableName:nil,
        sequenceNumber: nil,
        personallyIdentifiable: nil,
        displayNumber: nil
      }
      filtered_data = keys.reduce({}) do |m, (theirs, ours)|
        ours = theirs.to_s.underscore if !ours
        m[ours] = data[theirs]
        m
      end
      is_type_change = (data[:type] != question.question_type)
      filtered_data["question_type"] = data[:type]
      filtered_data[:form_question_conditions] = FormQuestionConditionsCreator.create(data[:conditions] || [])
      if !Permissions.user_can_view_personally_identifiable_answers_for_project?(user, structure.project)
        if question.personally_identifiable && !filtered_data["personally_identifiable"]
          question.errors[:personally_identifiable] << "You cannot unset the personally identifiable flag for this question"
          raise ActiveRecord::RecordInvalid.new question
        end
      end
      affects = {}
      ret_struct = nil
      needs_validation = needs_validation?(question, data)
      FormQuestion.transaction do
        AuditLogger.surround_edit(user, question) do
          if is_type_change
            QuestionTypeChanger.handle_type_change(question, data[:type])
          end
          question.assign_attributes filtered_data
          t = question.question_type
          if t == "radio" || t == "checkbox" || t == "yesno" || t == "dropdown" 
            affects = change_answer_choices(question, data)        
          else
            affects = change_question_exceptions(question, data)
          end
          
          if t == "numericalrange"
            config = data[:config]
            if question.numerical_range_config.nil? or question.numerical_range_config.destroyed?
              create_numerical_range_config(question, config)
            end
            question.numerical_range_config.minimum_value = config[:minValue]
            question.numerical_range_config.maximum_value = config[:maxValue]
            question.numerical_range_config.precision = config[:precision].to_s
          end

          if t == "text" and !data[:config].nil?
            question.text_config = TextConfig.create!(size: (data[:config][:size] || "large"))
          end
          question.save!
        end
        ret_struct = FormStructureQuestionReorderer.reorder(structure, question, prev_question_id)
      end
      (affects[:answers] || []).each do |a|
        FormAnswer.transaction do
          a.save!
        end
      end

      (affects[:conditions] || []).each do |c|
        FormQuestionCondition.transaction do
          c.save!
        end
      end

      (affects[:params] || []).each do |p|
        QueryParam.transaction do 
          p.save!
        end
      end
      if needs_validation
        answers = FormAnswer.where(form_question_id: question.id)
        answer_values = answers.pluck(:answer)
        FormAnswerProcessor.validate_and_save_all(user, question, answers, answer_values)
      end
      return ret_struct
    end

    def change_question_exceptions(question, data)
      new_reg_exceptions_hash = {}
      new_day_exceptions_hash = {}
      new_month_exceptions_hash = {}
      new_year_exceptions_hash = {}
      
      conditions = FormQuestionCondition.where("depends_on_id = ? and form_question_id IS NOT NULL", question.id)
      answers = FormAnswer.where(form_question_id: question.id) 
      query_params = QueryParam.where(form_question_id: question.id)
      
      old_exceptions = question.question_exceptions

      for old_exception in old_exceptions
        found = false
        for new_exception in (data[:exceptions] || [])
          if new_exception[:id] == old_exception.id
            found = true
          end
        end
        if !found
          answers.each do |answer| 
            raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"You can't delete an exception if it is being used as an answer.\"]}}"
          end
          old_exceptions.delete(old_exception)
          old_exception.destroy!
        end  
      end

      if question.question_type == "date"
        conditions.each do |condition|
          condition.value.gsub!("/", "\u200c")
        end
        query_params.each do |param|
          param.value.gsub!("/", "\u200c")
        end
      end


      for new_exception_data in (data[:exceptions] || [])
        new_exception_label = (new_exception_data[:label] || "").strip()
        new_exception_value = (new_exception_data[:value] || "").strip()
        if new_exception_data[:id] == nil  ## NEW EXCEPTION
          if new_exception_data[:value] && new_exception_data[:value] != "" || new_exception_data[:label] && new_exception_data[:label]
            new_exc = QuestionException.new({value: new_exception_value, label: new_exception_label, exception_type: new_exception_data[:exceptionType]})
            question.question_exceptions.push(new_exc)
            if new_exception_data[:exceptionType] == "numericalrange" || new_exception_data[:exceptionType] == "zipcode"
              QueryParam.where(form_question_id: question.id, value:  new_exception_value).update_all(is_regular_exception: true)
              FormAnswer.where(form_question_id: question.id, answer: new_exception_value).update_all(regular_exception: new_exc.id)
            end
          end
        else ## EXISTING EXCEPTION
          old_exception = (old_exceptions.select { |o| o.id == new_exception_data[:id]})[0]
          old_exception.label = new_exception_label
          if old_exception.exception_type != new_exception_data[:exceptionType]
            raise PayloadException.new 422, "{\"validations\":{\"exceptions\":[\"You cannot change an exception type.\"]}}"
          end

          if old_exception.value != new_exception_value  ##CHANGED EXISTING EXCEPTION
            rand = SecureRandom.base64(16)
            t = new_exception_data[:exceptionType]
            if t == "zipcode" || t== "numericalrange" || t == "email" || t == "timeofday"
              FormAnswer.where(regular_exception: new_exception_data[:id]).update_all(answer: new_exception_value)
              if t == "numericalrange" || t == "zipcode" 
                QueryParam.where(form_question_id: question.id, value:  new_exception_value).update_all(is_regular_exception: true)
                FormAnswer.where(form_question_id: question.id, answer: new_exception_value).update_all(regular_exception: new_exception_data[:id])
              end
              answers = []
              new_reg_exceptions_hash[new_exception_value] = rand
              conditions.each do |condition|
                if condition.value == old_exception.value
                  condition.value = rand
                end
              end
              query_params.each do |param|
                if param.value == old_exception.value
                  param.value = rand
                end
              end
            else
              answers.each do |answer|
                pattern = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/
                groups = pattern.match(answer.answer)

                if t =="date_day"
                  if answer.day_exception == new_exception_data[:id]
                    answer.answer = groups[1] + "/" + new_exception_value + "/" + groups[3]
                  end                
                elsif t == "date_month"
                  if answer.month_exception == new_exception_data[:id]
                    answer.answer = new_exception_value + "/" + groups[2] + "/" + groups[3]
                  end                  
                elsif t == "date_year"
                  if answer.year_exception == new_exception_data[:id]
                    answer.answer = groups[1] + "/" + groups[2] + "/" + new_exception_value
                  end
                end
              end

              query_params.each do |param|
                groups = param.value.split("\u200c")
                if t =="date_day"
                  new_day_exceptions_hash[new_exception_value] = rand
                  if groups[1] == old_exception.value
                    param.value = groups[0] + "\u200c" + rand + "\u200c" + groups[2]
                  end                
                elsif t == "date_month"
                  new_month_exceptions_hash[new_exception_value] = rand
                  if groups[0] == old_exception.value
                    param.value = rand + "\u200c" + groups[1] + "\u200c" + groups[2]
                  end                  
                elsif t == "date_year"
                  new_year_exceptions_hash[new_exception_value] = rand
                  if groups[2] == old_exception.value
                    param.value = groups[0] + "\u200c" + groups[1] + "\u200c" + rand
                  end
                end
              end
              conditions.each do |condition|
                groups = condition.value.split("\u200c")
                if t =="date_day"
                  new_day_exceptions_hash[new_exception_value] = rand
                  if groups[1] == old_exception.value
                    condition.value = groups[0] + "\u200c" + rand + "\u200c" + groups[2]
                  end                
                elsif t == "date_month"
                  new_month_exceptions_hash[new_exception_value] = rand
                  if groups[0] == old_exception.value
                    condition.value = rand + "\u200c" + groups[1] + "\u200c" + groups[2]
                  end                  
                elsif t == "date_year"
                  new_year_exceptions_hash[new_exception_value] = rand
                  if groups[2] == old_exception.value
                    condition.value = groups[0] + "\u200c" + groups[1] + "\u200c" + rand
                  end
                end
              end
            end 
            old_exception.value = new_exception_value
          end
        end
      end
      for new_exception_data in (data[:exceptions] || []) #changes conditions from hash to new val for all exisiting changed exceptions
        hash = {}
        if new_exception_data[:id]
          case new_exception_data[:exceptionType]
          when "zipcode", "numericalrange", "timeofday", "email"
            hash = new_reg_exceptions_hash
          when "date_day"
            hash = new_day_exceptions_hash
          when "date_month"
            hash = new_month_exceptions_hash
          when "date_year"
            hash = new_year_exceptions_hash
          end
          new_val = (new_exception_data[:value] || "").strip()
          
          query_params.each do |param|
            if hash[new_val]
              param.value_will_change!
              param.value.sub!(hash[new_val], new_val)
            end
            if question.question_type == "date"
              param.value_will_change!
              param.value.gsub!("\u200c", "/")
            end
          end

          conditions.each do |condition|
            if hash[new_val]
              condition.value_will_change!
              condition.value.sub!(hash[new_val], new_val)
            end
            if question.question_type == "date"
              condition.value_will_change!
              condition.value.gsub!("\u200c", "/")
            end
          end
        end
      end
      return {answers: answers, conditions: conditions, params: query_params} 
    end

    def change_answer_choices(question, data)
      config = question.option_configs
      new_option_hash = {}
      answers = FormAnswer.where("form_question_id = ?", question.id)
      query_params = QueryParam.where(form_question_id: question.id)
      conditions = FormQuestionCondition.where("depends_on_id = ? and form_question_id IS NOT NULL", question.id)

      for old_option in config
        found = false
        for new_option in (data[:config][:selections] || [])
          if new_option[:id] == old_option.id
            found = true
          end
        end
        if !found
          # TODO: implement these cases
          #answers.each do |answer|
          #  raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"You can't delete an option if the question has data.\"]}}"
          #end
          #conditions.each do |condition|
          #  raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"You can't delete an option if it is used in conditional logic.\"]}}"
          #end
          config.delete(old_option)
          old_option.destroy!
        end  
      end

      for new_option in (data[:config][:selections] || []) #changes options and adds new ones
        if new_option[:value].try(:strip) == "" or new_option[:value].try(:strip).nil?
          raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"Answer choices can not be empty.\"]}}"
        end
        if new_option["otherOption"] #other option validations
          if data[:type] == "dropdown"
            raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"Dropdown Question types can not have options with text boxes\"]}}"
          end
          if new_option[:otherVariableName] == nil
            raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"Textbox Options must have a variable name specified\"]}}"
          else
            question.form_structure.project.option_configs.where(other_variable_name: new_option[:otherVariableName]).each do |existing_option|
              if existing_option.id != new_option[:id]
                raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"This textbox variable name above is the same as another question's textbox variable name, please make it unique\"]}}"
              end
            end
            question.form_structure.project.form_questions.where(variable_name: new_option[:otherVariableName]).each do |existing_question|
              if existing_question.id != question.id 
                raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"The textbox variable name above is the same as another question's variable name, please make it unique\"]}}"
              end
            end
            if new_option[:otherVariableName] == data["variableName"]
              raise PayloadException.new 422, "{\"validations\":{\"variableName\":[\"The question's variable name is the same as the textbox variable name below, please make it unique\"]}}"
            end
     
          end
        end

        new_val = new_option[:value]
        if new_val == nil
          new_val = ""
        end
        new_val = new_val.strip()
        new_code = new_option[:code]
        new_other_var_name = new_option[:otherVariableName]
        rand = SecureRandom.base64(16)
        new_option_hash[new_val] = rand
        if new_option[:id] #existing options: changes answer(to hash) and changes option
          old_option = (config.select { |o| o.id == new_option[:id]})[0]
          if old_option.nil?
            question.option_configs.push(OptionConfig.create(value: new_val, index: question.option_configs.length, other_option: new_option[:otherOption], code: new_code, other_variable_name: new_other_var_name))
          else
            if old_option.code != new_code  # code change
              old_option.code = new_code
            end

            if old_option.other_variable_name != new_other_var_name # other var name changes
              old_option.other_variable_name = new_other_var_name
            end

            if old_option.value != new_val # value change
              answers.each do |answer|
                if question.question_type != "checkbox"
                  if old_option.other_option
                    if answer.answer && answer.answer.split("\u200a")[0] == old_option.value
                      answer.answer = rand + "\u200a" + answer.answer.split("\u200a")[1]
                    end
                  elsif answer.answer ==  old_option.value
                    answer.answer = rand
                  end
                else
                  parts = answer.answer.split("\u200c") ## fix this shit
                  parts.collect! do |part|

                    if old_option.other_option
                      if part && part.split("\u200a")[0] == old_option.value
                        part = rand + "\u200a" + (part.split("\u200a")[1] || "")
                      end
                    elsif part == old_option.value
                      part = rand
                    end
                    part
                  end
                  new_answer = ""
                  parts.each do |part|
                    if new_answer == ""
                      new_answer += part
                    else
                      new_answer += "\u200c" + part
                    end
                  end
                  answer.answer = new_answer
                end
              end
              conditions.each do |condition|
                if condition.value == old_option.value
                  condition.value = rand
                end
              end
              query_params.each do |param|
                if param.value == old_option.value
                  param.value = rand
                end
              end
              old_option.value = new_val
            end
          end

        else  #new options\
          if new_val != ""
            question.option_configs.push(OptionConfig.create(value: new_val, index: question.option_configs.length, other_option: new_option[:otherOption], code: new_code, other_variable_name: new_other_var_name))
          end
        end
      end

      for new_option in (data[:config][:selections] || []) #changes answers and conditions from hash to new val for all exisiting changed options
        if new_option[:id]
          new_val = new_option[:value]
          if new_val == nil
            new_val = ""
          end
          new_val = new_val.strip()
          answers.each do |answer|
            if answer.answer != nil
              answer.answer_will_change!
              answer.answer.sub!(new_option_hash[new_val], new_val)
            end
          end
          conditions.each do |condition|
            condition.value_will_change!
            condition.value.sub!(new_option_hash[new_val], new_val)
          end
          query_params.each do |param|
            param.value_will_change!
            param.value.sub!(new_option_hash[new_val], new_val)
          end
        end
      end
      return {answers: answers, conditions: conditions, params: query_params} 
    end

    def needs_validation?(question, data)
      if question.question_type != data[:questionType]
        return true
      end
      if question.question_type == "numericalrange"
        config = data[:config]
        if (question.numerical_range_config.nil?)
          return true
        end
        if (question.numerical_range_config.minimum_value != config[:minValue] or
            question.numerical_range_config.maximum_value != config[:maxValue] or
            question.numerical_range_config.precision != config[:precision].to_s)
          return true
        end
      end
      return false
    end

    def create_numerical_range_config(question, config_data)
      min = config_data[:minValue]
      max = config_data[:maxValue]
      unless /\A[-+]?[0-9]*\.?[0-9]+\Z/ =~ min
        min = nil
      end
      unless /\A[-+]?[0-9]*\.?[0-9]+\Z/ =~ max
        max = nil
      end
      question.numerical_range_config = NumericalRangeConfig.create({
        minimum_value: min,
        maximum_value: max,
        precision: config_data[:precision].to_s
      })
    end

  end
end
