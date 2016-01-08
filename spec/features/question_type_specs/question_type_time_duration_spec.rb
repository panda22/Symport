describe "creating a time duration question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create time duration question with a prompt" do
    preview_form_question "Time duration", "var1", "Whatever:"
    question_preview_has_time_duration_with_prompt "Whatever:"
  end

  it "allows users to create a question that depends on a time duration question" do
    create_form_question "Time duration", "var1", "Whatever:"

    create_dependent_form_question "Text Field", "var3", "Have you never been mellow?", { parents: [question: "Whatever:", logic: '>', value: ["10","20","1"]] }
    complete_form_and_enter_data
    enter_form_data 1, "Whatever:", ["10","22","1"]
    question_should_not_be_grayed_out 2, "Have you never been mellow?"
    enter_form_data 1, "Whatever:", ["8","55","34"]
    question_should_be_grayed_out 2, "Have you never been mellow?"
  end

  def question_preview_has_time_duration_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector ".time-duration"
    end
  end
end
