class FormResponseBuilder
  class << self
    def build(user, structure_record, subject_id)
      # TODO: add instance number to created response
      unless Permissions.user_can_enter_form_responses_for_form_structure?(user, structure_record)
        raise PayloadException.access_denied "You do not have access to enter responses for this form"
      end
      answers = structure_record.answerable_questions.map do |q| 
        FormAnswer.new(form_question: q) 
      end
      FormResponse.new(subject_id: subject_id, form_structure: structure_record, form_answers: answers)
    end
  end
end