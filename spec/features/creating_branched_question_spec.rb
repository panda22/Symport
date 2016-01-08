describe "creating branched questions" do
  it "allows users to create a branched question out of an existing one" do
    log_in_as_test_user
    create_new_form
    create_form_question "Text Field", "var1", "What's your name?"
    create_form_question "Multiple Choice", "var2", "Are you male or female?" do
      enter_answer_option "Male"
      enter_answer_option "Female"
      true
    end

    create_branched_question_out_of 2, "Are you male or female?" do
      see_that_condition_question_is_prefilled_with 1, "Are you male or female?"
      select_logic_and_value_for 1, "Are you male or female?", "=", "Female"
      fill_basic_question_info "Multiple Choice", "var3", "Have you ever been pregnant?" do
        enter_answer_option "Yes"
        enter_answer_option "No"
        true
      end
    end
    sleep 2
    question_preview_has_content "Are you male or female?", "Used in Conditional Logic"
    question_preview_has_content "Have you ever been pregnant?", "Shown Based on Conditional Logic"
    question_preview_has_radiobutton_with_prompt "Have you ever been pregnant?", ["Yes", "No"]
  end

  def question_preview_has_radiobutton_with_prompt(prompt, options)
    question_preview_has_content prompt do
      options.each do |opt|
        has_radiobutton opt
      end
    end
  end

  def has_radiobutton option_text
    within ".radio-option", text: option_text do
      page.should have_selector 'input[type=radio]'
    end
  end

  def see_that_condition_question_is_prefilled_with condition_number, prompt
    within all(".conditions")[condition_number-1] do
      within '.select-condition-question option', text: prompt do
        page.current_scope.should be_selected
      end
    end
  end

  def select_logic_and_value_for condition_number, prompt, logic, value
    within all(".conditions")[condition_number-1] do
      select_logic logic
      select_value value
    end
  end
end
