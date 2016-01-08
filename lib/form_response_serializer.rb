class FormResponseSerializer
  class << self
    def serialize(user, response, wants_answer_ids=false)
      all_instances = FormResponse.
          where(:form_structure_id => response.form_structure_id, :subject_id => response.subject_id).
          #where("instance_number != ?", response.instance_number).
          order(:instance_number).map do |record|
            {
                instanceNumber: record.instance_number,
                secondaryId: record.secondary_id
            }
          end

      answers = response.form_answers
      structure = response.form_structure
      serialized_resp = {}

      serialized_resp[:id] = response.id
      serialized_resp[:formStructure] = FormStructureSerializer.serialize(user, structure, false)
      serialized_resp[:answers] = []
      serialized_resp[:subjectID] = response.subject_id || ""
      serialized_resp[:instanceNumber] = response.instance_number
      serialized_resp[:secondaryId] = response.secondary_id
      serialized_resp[:allInstances] = all_instances

      known_subjects = SubjectLookup.known_subjects_of_project(structure.project)
      serialized_resp[:updatedAt] = response.updated_at
      serialized_resp[:newSubject] = !known_subjects.include?(response.subject_id)

      can_phi = Permissions.user_can_view_personally_identifiable_answers_for_project?(user, structure.project)
      questions_and_answers = response.form_structure.form_questions.map do |question|
        [question, answers.detect { |answer| answer.form_question == question }]
      end

      serialized_resp[:answers] = questions_and_answers.map do |(question, answer)|
        FormAnswerSerializer.serialize(answer, question, can_phi, wants_answer_ids)
      end

      # TODO: do we need this?
      #answerable_questions = questions_and_answers.reject do |(question, answer)|
      #  QuestionTypes.formatting_types.include? question.question_type
      #end

      serialized_resp
    end

    def serialize_subjects(response_hash)
      response_hash.map do |subject_id, responses|
        {
            subjectID: subject_id,
            responses: responses
        }
      end
    end


  end
end
