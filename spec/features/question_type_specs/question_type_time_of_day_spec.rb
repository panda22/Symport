describe "creating a time of day question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create time of day question with a prompt" do
    preview_form_question "Time of day", "var1", "Whenever:"
    view_question_preview
    question_preview_has_time_of_day_with_prompt "Whenever:"
  end

  it "allows users to create a question that depends on a time of day question" do
    create_form_question "Time of day", "var1", "Whatever:"

    create_dependent_form_question "Text Field", "var3", "Have you never been mellow?", { parents: [question: "Whatever:", logic: '≤', value: ['8','21','PM']] }
    complete_form_and_enter_data
    enter_form_data 1, "Whatever:", ["8","21","PM"]
    question_should_not_be_grayed_out 2, "Have you never been mellow?"
    enter_form_data 1, "Whatever:", ["8","22","PM"]
    question_should_be_grayed_out 2, "Have you never been mellow?"
  end


  def question_preview_has_time_of_day_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector ".time-of-day"
    end
  end
end
