describe "creating a phone number question" do
  before do
    log_in_as_test_user
    create_new_form
  end
  it "allows users to create a phone number question with a prompt" do
    preview_form_question "Phone number", "var1", "Whatever:"
    question_preview_has_phone_number_with_prompt "Whatever:"
  end

  it "allows users to create a question that depends on a phone number question" do
    create_form_question "Phone number", "var1", "Whatever:"

    create_dependent_form_question "Text Field", "var3", "Have you never been mellow?", { parents: [question: "Whatever:", logic: '≠', value: ['608','555','1234']] }
    complete_form_and_enter_data
    enter_form_data 1, "Whatever:", ["608","333","1234"]
    question_should_not_be_grayed_out 2, "Have you never been mellow?"
    enter_form_data 1, "Whatever:", ["608","555","1234"]
    question_should_be_grayed_out 2, "Have you never been mellow?"
  end

  def question_preview_has_phone_number_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector ".phone-number"
    end
  end
end
