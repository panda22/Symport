class FormDataErrorConstructor
  class << self
    def construct_from_questions(errors_rs)
      result = {}
      errors_rs.each do |record|
        unless result.has_key?(record["question_id"])
          result[record["question_id"]] = []
        end
        answer = record["answer"]
        other_answer = ""
        if record["has_other_type"] == 1 or record["has_other_type"] == "1"
          temp_answer_val = ""
          answer.split("\u200c").each_with_index do |answer_part, i|
            if i != 0
              temp_answer_val += "\u200c"
            end
            if answer_part.include?("\u200a") and answer_part.split("\u200a").length == 2
              other_answer = answer_part.split("\u200a")[1]
              temp_answer_val += answer_part.split("\u200a")[0]
            else
              temp_answer_val += answer_part
            end
          end
          answer = temp_answer_val
        end
        new_error_obj = {
            responseID: record["response_id"],
            message: record["message"],
            questionID: record["question_id"],
            answerID: record["answer_id"],
            isActive: (record["ignore_error"] == "f"),
            subjectID: record["subject_id"],
            secondaryId: record["secondary_id"],
            answer: answer,
            otherAnswer: other_answer
        }
        # if record["ignore_error"] == 't' # default true value for rs
        #   result[record["question_id"]][:ignoredErrors].push(new_error_obj)
        # elsif record["ignore_error"] == 'f' # default false value for rs
        #   result[record["question_id"]][:activeErrors].push(new_error_obj)
        # end
        result[record["question_id"]].push(new_error_obj)
      end
      result
    end
  end
end