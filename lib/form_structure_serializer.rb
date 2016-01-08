class FormStructureSerializer
  class << self
    def serialize(user, record, include_questions)
      serialize_with_permissions(user, record, include_questions, nil)
    end
    def serialize_with_permissions(user, record, include_questions, user_permsissions)
      record = FormStructure.
          includes(:form_questions).
          includes(:option_configs).
          includes(:numerical_range_configs).
          includes(:form_question_conditions).
          includes(:question_exceptions).
          find(record.id)
      
      permissions = {}
      if user_permsissions
        permissions = user_permsissions
        #permission[:viewData] = user_permsissions[:viewData]
        #permission[:viewPhiData] = user_permsissions[:viewPhiData]
      else
        permissions = FormLevelPermissionsSerializer.serialize(user, record)
      end
      ShallowRecordSerializer.serialize(record, :id, :name).merge(
      {
        colorIndex: record.color_index,
        description: record.description,
        isManyToOne: record.is_many_to_one,
        secondaryId: record.secondary_id,
        isSecondaryIdSorted: record.is_secondary_id_sorted,
        responsesCount: record.form_responses.size,
        lastEdited: record.updated_at ? record.updated_at.iso8601 : nil,
        userPermissions: permissions
      }).tap do |output|
        if include_questions
          output[:questions] = record.form_questions.map do |q|
            FormQuestionSerializer.serialize(q)
          end
        end
      end
    end
  end
end
