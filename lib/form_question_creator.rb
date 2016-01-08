module FormQuestionCreator
  class << self
    def create(user, structure, data, prev_question_id=nil)
      if !Permissions.user_can_edit_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have permissions to add questions to this form"
      end
      FormQuestion.transaction do
        question = FormRecordCreator.create_question(data, structure)
        AuditLogger.add(user, question)
        FormStructureQuestionReorderer.reorder structure, question, prev_question_id
        structure
      end
    end
  end
end
