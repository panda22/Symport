class ProjectCodebookBuilder
  class << self

    def generate_codebook(project, structures, empty_code, closed_code, page_header_text_1)
      headers_row = ["Question Number","Variable Name","Question Text and Hint","Identifying Information?","Question Type and Format","Coded Value\n= Answer Choice","(Conditional Logic) Question Shown If:"]
      tables = []
      form_names = []
      for struct in structures
        table_grid = []
        table_grid.push headers_row
        for row in grid_for_form(struct)
          table_grid.push row
        end
        tables.push table_grid 
        form_names.push struct.name    
      end
    
      
      logo_path = "#{Rails.root}/app/assets/images/symport-print-logo.jpg"
      normal_font_path = "#{Rails.root}/app/assets/fonts/OpenSans-Regular.ttf"
      bold_font_path = "#{Rails.root}/app/assets/fonts/OpenSans-Semibold.ttf"

      content_font_size = 11

      page_header_text_2 = "Visit www.symportresearch.com to learn more."
      condition_coding_message = "Answers not shown due to conditional logic are coded as: #{closed_code}"
      empty_coding_message = "Answers that are empty are coded as: #{empty_code}"


      Prawn::Document.new(:page_layout => :landscape) do
        font_families.update("OpenSans" => {
          :normal => normal_font_path,
          :bold => bold_font_path
        })
        font "OpenSans"


        text page_header_text_1, :size => content_font_size
        move_down 5
        text page_header_text_2, :size => content_font_size


        image logo_path, :position => :right, :vposition => :top, :width => 110, :height => 30
        
        text "#{project.name}'s Codebook", :style => :bold, :size => 20
        text condition_coding_message, :size => content_font_size
        text empty_coding_message, :size => content_font_size
        move_down 15
        i = 0
        for form_code_table in tables
          unless i == 0
            start_new_page
            text page_header_text_1, :size => content_font_size
            move_down 5
            text page_header_text_2, :size => content_font_size
            image logo_path, :position => :right, :vposition => :top, :width => 110, :height => 30
          end
          form_name = form_names[i]
          i = i + 1
          text "Form: #{form_name}", :style => :bold, :size => 16
          move_down 10
          table(form_code_table, :header => true, :row_colors => ["FFFFFF","F2F2F2"]) do
            column(0).width = 67
            column(0).style :align => :center
            column(1).width = 75
            column(2).width = 141
            column(3).width = 85
            column(3).style :align => :center
            column(4).width = 93
            column(5).width = 122
            column(6).width = 137
            column(0..6).style :size => content_font_size, :border_colors => "CCCCCC"
            row(0).style :font_style => :bold
          end
        end

        number_pages "<page> of <total>", {:align => :right, :at => [bounds.right - 50, 0]}

      end.render
    end

    def grid_for_form(structure)
      questions = FormQuestion.where(form_structure_id: structure.id).order(:sequence_number)
      questions_hash = {}
      for q in questions
        questions_hash[q.id] = q
      end
      grid = []
      for question in questions
        for row in row_or_rows_for_question(question, questions_hash)
          grid.push row
        end
      end
      return grid
    end

    def row_or_rows_for_question(question, questions_hash)
      if question.question_type == "header"
        return []
      end

      num = question.sequence_number
      var = question.variable_name
      prompt_hint = question.prompt + "\n" + (question.description || "")
      phi = ""
      if question.personally_identifiable
        phi = "Yes"
      end
      type_validator = cell_for_type_format(question)
      choices_other = cell_for_answer_choices_or_exceptions(question)
      choices = choices_other[0]
      other = choices_other[1]
      logic = cell_for_conditional_logic(question,questions_hash)
      if other == nil
        return [[num, var, prompt_hint, phi, type_validator, choices, logic]]
      else
        return [[num, var, prompt_hint, phi, type_validator, choices, logic],[num, other.other_variable_name, prompt_hint, phi, type_validator+"\nTextbox", other.code+"="+other.value, ""]]
      end
    end
    
    def cell_for_answer_choices_or_exceptions(question)
      other = nil
      t = question.question_type
      str = ""
      if t == "radio" || t == "checkbox" || t == "dropdown" || t == "yesno"
        for option in question.option_configs
          str = str + option.code + "=" + option.value + ",\n"
          if option.other_option
            other = option
          end
        end
        return [str.slice(0, str.length-2), other]
      elsif t == "numericalrange" || t == "timeofday" || t == "zipcode" || t == "email"
        for exception in question.question_exceptions
          str = str + exception.value + "=" + exception.label + ",\n"
        end
        return [str.slice(0, str.length-2), other]
      elsif t == "date"
        first = true
        for exception in question.question_exceptions.where(exception_type: "date_day")
          if first
            str = str + "Day Codes\n"
          end
          first = false
          str = str + exception.value + " = " + exception.label + ",  "
        end
        unless first
          str = str.slice(0, str.length-3)
        end
        first = true
        for exception in question.question_exceptions.where(exception_type: "date_month")
          if first
            if str != ""
              str = str + "\n-------\n"
            end
            str = str + "Month Codes\n"
            first = false
          end
          str = str + exception.value + " = " + exception.label + ",  "
        end
        unless first
          str = str.slice(0, str.length-3)
        end
        first = true
        for exception in question.question_exceptions.where(exception_type: "date_year")
         if first
            if str != ""
              str = str + "\n-------\n"
            end
            str = str + "Year Codes\n"
            first = false
          end
          str = str + exception.value + " = " + exception.label + ",  "
        end
        unless first
          str = str.slice(0, str.length-3)
        end
        return [str,other]
      else       
        return ["",other]
      end
    end



    def cell_for_conditional_logic(question, questions_hash)
      op_hash = {}
      op_hash['='] = " = "
      op_hash['<>'] = " ≠ "
      op_hash['<'] = " < "
      op_hash['>'] = " > "
      op_hash['<='] = " ≤ "
      op_hash['>='] = " ≥ "
      str = ""
      for condition in question.form_question_conditions
        op = op_hash[condition.operator]
        str = str + "[" + questions_hash[condition.depends_on_id].variable_name + op + (condition.value || '') + "]\n&\n"
      end
      if str == ""
        return str
      end
      return str.slice(0,str.length-3)
    end

    def cell_for_type_format(question)
      case question.question_type
      when "date"
        return "Date\n" + "mm/dd/yyyy"
      when "zipcode"
        return "Zipcode\n" + "#####"
      when "email"
        return "Email\n" + "example@example.com"
      when "timeofday"
        return "Time of day\n" + "HH:MM [AM|PM]"
      when "timeduration"
        return "Time duration\n" + "HH:MM:SS"
      when "numericalrange"
        config = question.numerical_range_config
        return "Number\n" + "Min: #{config.minimum_value || "'none'"}\nMax:#{config.maximum_value || "'none'"}\nPrecision:#{config.precision}"
      when "phonenumber"
        return "Phone Number\n" + "(###)-###-####x###"
      when "text"
        return "Text"
      when "checkbox"
        return "Checkbox\n(Select Many)"
      when "radio"
        return "Multiple Choice\n(Select One)"
      when "dropdown"
        return "Dropdown\n(Select One)"
      when "yesno"
        return "Yes/No\n(Select One)"
      end
    end
  end
end