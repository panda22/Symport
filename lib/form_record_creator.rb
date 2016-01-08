class FormRecordCreator
  class << self
    def create_structure(project, data)
      num_structures = project.form_structures.count
      structure = FormStructure.create project: project, name: data[:name].try(:strip), is_many_to_one: data[:isManyToOne], secondary_id: data[:secondaryId], description: data[:description]
      max_num_secondary_id_tries = 10
      index = 1
      if structure.secondary_id != nil and structure.secondary_id.try(:downcase).include? "secondary id"
        index = 1
        while structure.valid? == false and structure.errors.messages.has_key?(:secondary_id)
          structure.secondary_id = "Secondary ID (#{index})"
          if index == max_num_secondary_id_tries
            structure.secondary_id = "Secondary ID (#{SecureRandom.urlsafe_base64})"
          end
          index += 1
        end
      end
      structure.color_index = (project.form_structures.count-1)%11
      structure.save!
      structure
    end

    def create_question(data, structure)
      (data[:exceptions] || []).select! do |exception_data| 
        exception_data[:value] && exception_data[:value] != "" || exception_data[:label] && exception_data[:label] != ""
      end 
      FormQuestion.new({
        question_type: data[:type],
        sequence_number: data[:sequenceNumber],
        variable_name: data[:variableName],
        prompt: data[:prompt],
        description: data[:description],
        personally_identifiable: data[:personallyIdentifiable],
        display_number: data[:displayNumber],
        form_structure: structure,
        form_question_conditions: FormQuestionConditionsCreator.create(data[:conditions] || []),
        question_exceptions: (data[:exceptions] || []).map do |exception_data|
          QuestionException.new({value: (exception_data[:value] || "").strip(), label: (exception_data[:label] || "").strip(), exception_type: exception_data[:exceptionType]})
        end

      }).tap do |q|
        config = data[:config]
        case q.question_type
        when 'text'
          q.text_config = TextConfig.create(size: config[:size])
        when 'numericalrange'
          min = config[:minValue]
          max = config[:maxValue]
          unless /\A[-+]?[0-9]*\.?[0-9]+\Z/ =~ min
            min = nil
          end
          unless /\A[-+]?[0-9]*\.?[0-9]+\Z/ =~ max
            max = nil
          end
          q.numerical_range_config = NumericalRangeConfig.create({
            minimum_value: min,
            maximum_value: max,
            precision: config[:precision].to_s
          })
        when 'radio', 'checkbox', 'yesno', 'dropdown'
          if config[:selections].present?
            i = -1
            temp_configs = config[:selections].map do |s| 
              if s[:otherOption]
                if q.question_type == "dropdown"
                  raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"Dropdown Question types can not have options with text boxes\"]}}"
                end
                if s[:otherVariableName] == nil
                  raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"Textbox Options must have a variable name specified\"]}}"
                else
                  structure.project.option_configs.where(other_variable_name: s[:otherVariableName]).each do |option|
                    raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"This textbox variable name above is the same as another question's textbox variable name, please make it unique\"]}}"
                  end
                  structure.project.form_questions.where(variable_name: s[:otherVariableName]).each do |question|
                    raise PayloadException.new 422, "{\"validations\":{\"optionConfigs\":[\"The textbox variable name above is the same as another question's variable name, please make it unique\"]}}"
                  end
                  if s[:otherVariableName] == data["variableName"]
                    raise PayloadException.new 422, "{\"validations\":{\"variableName\":[\"The question's variable name is the same as the textbox variable name below, please make it unique\"]}}"
                  end
                end
              end
              if (s[:value] || "").strip != ""
                i = i + 1
                OptionConfig.create(value: (s[:value]).strip(), index: i, other_option: s[:otherOption], code: s[:code], other_variable_name: s[:otherVariableName]) 
              end
            end
                        
            q.option_configs = temp_configs.compact

          end
        end
        q.save!
      end
    end

    def create_answer(question)
      FormAnswer.create! form_question: question
    end

    def create_response(subject_id, structure, answers, instance_number, secondary_id=nil)
      FormResponse.create! subject_id: subject_id, form_structure: structure, form_answers: answers, instance_number: instance_number, secondary_id: secondary_id
    end

    def new_answer(question)
      FormAnswer.new form_question: question
    end

    def new_response(subject_id, structure, answers, instance_number)
      FormResponse.new subject_id: subject_id, form_structure: structure, form_answers: answers, instance_number: instance_number
    end

  end
end
