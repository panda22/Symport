class VariableNameValidator < ActiveModel::Validator
  def validate(record)
    new_variable_name = record[:variable_name]
    if !QuestionTypes.formatting_types.include?(record[:question_type])
      if new_variable_name.blank?
        record.errors[:variableName] << "Please enter a variable name before saving"
      else
        project = record.form_structure.try(:project)
        if project.present?
          matching_question = project.form_questions.where.not(id: record.id).find_by(variable_name: new_variable_name)
          if matching_question.present?
            record.errors[:variableName] << "The variable name is the same as another question's variable name, please make it unique"
          end
          project.option_configs.where(other_variable_name: new_variable_name).each do |existing_option|
            if record[:id] != existing_option.form_question.id
              record.errors[:variableName] << "The variable name is the same as another question's textbox variable name, please make it unique"
            end  
          end
        end
      end
    end
  end
end
