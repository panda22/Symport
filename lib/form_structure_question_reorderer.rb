class FormStructureQuestionReorderer
  class << self
    def reorder(structure, preserve_number_question=nil, prev_question_id=nil)
      questions_array = structure.form_questions.to_a
      questions_array.delete preserve_number_question if preserve_number_question.present?
      questions_array.sort! do |q1, q2|
        q1.sequence_number <=> q2.sequence_number
      end
      if preserve_number_question.present?
        if prev_question_id.present? #add preserve after question having id==prev_question_id
          temp_question_array = []
          questions_array.each do |question|
            #unless question.id == preserve_number_question.id
            temp_question_array.push question
            #end
            if question.id == prev_question_id
              temp_question_array.push preserve_number_question
            end
          end
          questions_array = temp_question_array
        else
          questions_array.insert (preserve_number_question.sequence_number-1), preserve_number_question
        end
      end
      questions_array.reject!(&:blank?)
      questions_array.each_with_index do |q, i|
        q.sequence_number = (i+1)
      end
      FormStructure.transaction do
        questions_array.each(&:save!)
        invalid = questions_array.any? do |q|
          q.form_question_conditions.any? do |cond|
            cond.invalid? && FormQuestion.deleted.where(id: cond.depends_on_id) == []
          end
        end
        if invalid
          raise PayloadException.validation_error conditions: "conditions are invalid"
        end
      end
      structure.touch
      structure.reload
    end
  end
end
