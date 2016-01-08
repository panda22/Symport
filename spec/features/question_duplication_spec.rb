describe "duplicating questions" do
  it "allows users to duplicate an existing question" do
    log_in_as_test_user
    create_new_form
    create_form_question "Text Field", "var1", "First question"
    create_form_question "Checkbox", "var2", "Some of these:" do 
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end
    create_form_question "Text Field", "var3", "Third question"
    question_preview_has_checkbox_with_prompt "Some of these:", ["Snap", "Crackle", "Pop"]

    edit_question 2, "Some of these:" do
      see_that_type_can_be_changed "Checkbox"
      false
    end

    duplicate_question 2, "Some of these:" do
      see_that_type_can_be_changed "Checkbox"
      select_type "Date Field"
      enter_prompt "When did we duplicate this question?"
      true
    end

    question_preview_has_checkbox_with_prompt "Some of these:", ["Snap", "Crackle", "Pop"]
    question_preview_has_content "When did we duplicate this question?"
  end

  def question_preview_has_checkbox_with_prompt(prompt, options)
    question_preview_has_content prompt do
      options.each do |opt|
        has_checkbox opt
      end
    end
  end

  def has_checkbox option_text
    within ".checkbox-option", text: option_text do
      page.should have_selector 'input[type=checkbox]'
    end
  end
end
