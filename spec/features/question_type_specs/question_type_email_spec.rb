describe "creating a email question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create email question with a prompt" do
    create_form_question "Email", "var1", "Send issues:"
    complete_form_and_enter_data
    answer_has_email_with_prompt "Send issues:"
  end

  it "allows users to create a question dependent on email value" do
    create_form_question "Email", "var2", "Send issues:"

    create_dependent_form_question "Text Field", "var3", "Have you ever been pregnant?", { parents: [question: "Send issues:", logic: '≠', value: 'john@smith.com'] }
    complete_form_and_enter_data
    enter_form_data 1, "Send issues:", "allowed@gmail.com"
    question_should_not_be_grayed_out 2, "Have you ever been pregnant?"
    enter_form_data 1, "Send issues:", "john@smith.com"
    question_should_be_grayed_out 2, "Have you ever been pregnant?"
  end


  def answer_has_email_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector "input.email"
    end
  end


  def fill_email(some_text)
    find(".email").set some_text
    find(".email").trigger "blur"
  end
end
