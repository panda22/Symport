class FormDataAnswerFormatter
  class << self
    def format_and_push(row, record, other_question_hash)
      if record["has_other_type"] == "0"
        handle_normal_answer(row, record)
      else
        handle_other_answer(row, record, other_question_hash)
      end
    end

    private
    def handle_normal_answer(row, record)
      answer = (record["answer"] || "").split("\u200c").join(" ● ")
      var_name = record["var_name"]
      row.push({variableName: var_name, value: answer, answerID: record["answer_id"]})
    end

    def handle_other_answer(row, record, other_question_hash)
      answer_parts = (record["answer"] || "").split("\u200c")
      first_answer = ""
      second_answer = ""
      answer_parts.each_with_index do |part, i|
        if i != 0
          first_answer += " ● "
        end
        if part.include?("\u200a")
          first_answer += part.split("\u200a")[0]
          second_answer = part.split("\u200a")[1]
        else
          first_answer += part
        end
      end

      var_name = record["var_name"]
      row.push({variableName: var_name, value: first_answer, answerID: record["answer_id"]})

      question_id = record["question_id"]
      other_var_name = other_question_hash[question_id]
      row.push({variableName: other_var_name, value: second_answer})
    end

  end
end