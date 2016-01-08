class FormDataGridConstructor
  class << self
    def construct_body(form, responses, other_question_hash)
      result = []
      new_row = nil
      cur_response_id = nil
      responses.each do |response|
        if cur_response_id != response["response_id"]
          cur_response_id = response["response_id"]
          unless new_row == nil
            result.push(new_row)
          end
          new_row = [
              {
                  variableName: "subjectID",
                  value: response["subject_id"],
                  responseID: cur_response_id,
                  created: response["response_created_at"].to_time.to_i,
                  updated: response["response_updated_at"].to_time.to_i
              }
          ]
          if form.is_many_to_one
            no_space_id = form.secondary_id.split(" ").join("_")
            new_row.push({variableName: no_space_id, value: response["secondary_id"]})
          end
        end
        FormDataAnswerFormatter.format_and_push(new_row, response, other_question_hash)
      end
      unless new_row == nil
        result.push(new_row)
      end

      # question_hash = get_form_question_hash(questions)
      # result = []
      # responses.each do |response|
      #   new_row = [
      #       {variableName: "subjectID", value: response.subject_id},
      #       {variableName: "filledPercent", value: "0"}
      #   ]
      #   response.form_answers.each do |answer|
      #     var_name = question_hash[answer.form_question_id].variable_name
      #     new_row.push({variableName: var_name, value: answer.answer})
      #   end
      #   result.push(new_row)
      # end
      result
    end

    def construct_header(form, questions, other_question_hash)
      left = [
          {
              id: "subject-id",
              name: "Subject ID",
              field: "subjectID"
          }
      ]
      right = [
          # {
          #     id: "filled-percent",
          #     name: "Filled Percent",
          #     field: "filledPercent"
          # }
      ]
      if form.is_many_to_one
        # TODO: do spaces in secondary id break stuff?
        no_space_id = form.secondary_id.split(" ").join("_")
        left.push({
                       id: no_space_id,
                       name: no_space_id,
                       field: no_space_id
                   })
      end
      questions.each do |question|
        obj = {
            id: question.id,
            name: question.variable_name,
            field: question.variable_name
        }
        right.push(obj)
        if other_question_hash.has_key?(question.id)
          obj = {
              id: other_question_hash[question.id],
              name: other_question_hash[question.id],
              field: other_question_hash[question.id]
          }
          right.push(obj)
        end
      end
      [left, right]
    end

    def construct_other_question_hash(other_questions_rs)
      result = {}
      other_questions_rs.each do |record|
        question_id = record["question_id"]
        var_name = record["var_name"]
        result[question_id] = var_name
      end
      result
    end

    private
    def get_form_question_hash(questions)
      new_hash = {}
      questions.each do |question|
        new_hash[question.id] = question
      end
      new_hash
    end


  end
end