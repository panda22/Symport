class FormResponseAnswersUpdater
  class << self
    def update(user, response_record, new_answers)
      structure = response_record.form_structure
      can_view_phi = Permissions.user_can_view_personally_identifiable_answers_for_project?(user, structure.project)

      errors = structure.answerable_questions.reduce({}) do |err, question|
        if !question.personally_identifiable or can_view_phi
          err.merge(FormQuestionAnswerUpdater.update(user, question, response_record, new_answers))
        else
          err
        end
      end
        if errors.keys.any?
         raise PayloadException.new 422, {
           validations: { answers: errors }
         }
      end
    end

    def get_errors(user, response_record, new_answers)
      structure = response_record.form_structure
      
      errors = structure.answerable_questions.reduce({}) do |err, question|
        err.merge(FormQuestionAnswerUpdater.validate(user, question, new_answers))
      end
        if errors.keys.any?
         raise PayloadException.new 422, {
           validations: { answers: errors }
         }
      end
    end

  end
end
