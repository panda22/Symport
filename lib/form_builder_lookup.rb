class FormBuilderLookup
  class << self

    def find_question(user, id)
      FormQuestion.find(id).tap do |question| verify_question_access user, question end
    end

    def find_structure(user, id)
      form = FormStructure.
          includes(:form_questions).
          includes(:option_configs).
          includes(:numerical_range_configs).
          includes(:form_question_conditions).
          includes(:question_exceptions).
          find(id)#.tap do |structure| verify_structure_access user, structure end
      verify_structure_access(user, form)
      form
    end

    private
    def verify_question_access(user, question)
      if question.present?
        verify_structure_access user, question.form_structure
      end
    end

    def verify_structure_access(user, structure)
      if structure.present? and !Permissions.user_can_see_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have access to this form"
      end
    end

  end
end
