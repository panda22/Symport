describe "creating a yes-no question" do
  before do
    log_in_as_test_user
    create_new_form
  end
  it "allows users to create yes-no question with a prompt" do
    preview_form_question "Yes/No", "var1", "Are symptoms present?"
    question_preview_has_yes_no_with_prompt "Are symptoms present?"
  end

  it "allows users to create a question that depends on a yes-no value" do
    create_form_question "Yes/No", "var1", "Are symptoms present?"

    create_dependent_form_question "Text Field", "var3", "Have you never been mellow?", { parents: [question: "Are symptoms present?", logic: '=', value: 'Yes'] }
    complete_form_and_enter_data
    enter_form_data 1, "Are symptoms present?", "Yes"
    question_should_not_be_grayed_out 2, "Have you never been mellow?"
    enter_form_data 1, "Are symptoms present?", "No"
    question_should_be_grayed_out 2, "Have you never been mellow?"
  end

  def question_preview_has_yes_no_with_prompt(prompt)
    question_preview_has_content prompt do
      has_yes_option "Yes"
      has_no_option "No"
    end
  end

  def has_yes_option option_text
    within ".radio-option:first-of-type", text: option_text do
      page.should have_selector 'input[type=radio]'
    end
  end

  def has_no_option option_text
    within ".radio-option:last-of-type", text: option_text do
      page.should have_selector 'input[type=radio]'
    end
  end
end
