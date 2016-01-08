describe "creating a date question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create date question with a prompt" do
    preview_form_question "Date Field", "var1", "Whenever:"
    question_preview_has_date_with_prompt "Whenever:"
  end

  it "allows users to create a question dependent on date value" do
    create_form_question "Date Field", "var2", "Whatever:"

    create_dependent_form_question "Text Field", "var3", "Have you ever been pregnant?", { parents: [question: "Whatever:", logic: '>', value: '08/29/2020'] }
    complete_form_and_enter_data
    enter_form_data 1, "Whatever:", "04/10/2021"
    question_should_not_be_grayed_out 2, "Have you ever been pregnant?"
    enter_form_data 1, "Whatever:", "04/10/2019"
    question_should_be_grayed_out 2, "Have you ever been pregnant?"
  end

  def question_preview_has_date_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector "input.date-entry"
    end
  end
end
