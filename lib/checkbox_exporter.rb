class CheckboxExporter
  class << self

    def add_question_to_header(header, question, var_name, use_codes=false)
      question.option_configs.map do |config|
        new_var_name = "#{var_name}:#{config.value}"
        header.push({
          value: new_var_name,
          type: question.question_type
        })
        if use_codes and config.code != nil
          config.code
        else
          config.value
        end
      end
    end

    def add_answer_to_grid(grid, index, answer_choices, answer, empty_code = "", use_codes=false)
      if answer.nil?
        answer_choices.each do
          grid[index].push({
            value: empty_code,
            is_exception: false
          })
        end
        return
      end
      answer_hash = {}
      answer.split("\u200C").each do |answer_part|
        no_other_answer = answer_part.split("\u200A").first
        answer_hash[no_other_answer] = true
      end
      answer_choices.each do |answer_choice|
        if answer_hash[answer_choice]
          final_answer = (use_codes) ? 1 : answer_choice
          grid[index].push({
            value: final_answer,
            is_exception: false
          })
        else
          grid[index].push({
            value: "",
            is_exception: false
          })
        end
      end
    end

  end
end