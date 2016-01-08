describe "creating a checkboxes question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "chooses question type and sees initial answer choice" do
    preview_form_question "Multiple Choice", "var0", "One of these:" do
      page.assert_selector('.option-value', :count => 1)
    end
  end

  it "allows users to create radio button question with a prompt" do
    preview_form_question "Multiple Choice", "var1", "One of these:" do
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end
    question_preview_has_radiobutton_with_prompt "One of these:"
  end

  it "allows users to create a question dependent on radiobutton value" do
    create_form_question "Multiple Choice", "var2", "One of these:" do
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end

    create_dependent_form_question "Text Field", "var3", "Have you ever been pregnant?", { parents: [question: "One of these:", logic: '=', value: 'Pop'] }
    complete_form_and_enter_data
    enter_form_data 1, "One of these:", "Pop"
    question_should_not_be_grayed_out 2, "Have you ever been pregnant?"
    enter_form_data 1, "One of these:", "Snap"
    question_should_be_grayed_out 2, "Have you ever been pregnant?"
  end

  def question_preview_has_radiobutton_with_prompt(prompt)
    question_preview_has_content prompt do
      has_radiobutton "Snap"
      has_radiobutton "Crackle"
      has_radiobutton "Pop"
    end
  end

  def has_radiobutton option_text
    within ".radio-option", text: option_text do
      page.should have_selector 'input[type=radio]'
    end
  end
end
