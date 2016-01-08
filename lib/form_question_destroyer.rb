class FormQuestionDestroyer
  class << self
    def destroy(user, question, structure)
      if !Permissions.user_can_edit_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have permission to remove questions from this form"
      end
      FormQuestion.transaction do
        question.destroy!
        question.form_question_conditions.each(&:destroy!)
        question.dependent_conditions.each(&:destroy!)
        #question.question_exceptions.each(&:destroy!)
        question.form_answers.each(&:destroy)
        QueryChangeUpdater.update_from_form_question(question, true)
        AuditLogger.remove(user, question)
        structure = FormStructure.find(question.form_structure_id)
        FormStructureQuestionReorderer.reorder(structure)
      end
    end
  end
end
