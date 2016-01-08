describe "creating a checkboxes question" do

  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create checkbox question with a prompt" do
    preview_form_question "Checkbox", "var1", "Some of these:" do
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end
    question_preview_has_checkbox_with_prompt "Some of these:"
  end

  it "allows users to create a question dependent on checkbox value" do
    create_form_question "Checkbox", "var2", "Some of these:" do
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end

    create_dependent_form_question "Text Field", "var3", "Have you ever been pregnant?", { parents: [question: "Some of these:", logic: 'contains', value: 'Pop'] }
    complete_form_and_enter_data
    enter_form_data 1, "Some of these:", "Pop"
    question_should_not_be_grayed_out 2, "Have you ever been pregnant?"
    enter_form_data 1, "Some of these:", "Snap"
    question_should_be_grayed_out 2, "Have you ever been pregnant?"
  end

  def question_preview_has_checkbox_with_prompt(prompt)
    question_preview_has_content prompt do
      has_checkbox "Snap"
      has_checkbox "Crackle"
      has_checkbox "Pop"
    end
  end

  def has_checkbox option_text
    within ".checkbox-option", text: option_text do
      page.should have_selector 'input[type=checkbox]'
    end
  end
end
