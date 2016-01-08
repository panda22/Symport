describe "creating a header question" do
  it "allows users to create header question with a prompt" do
    log_in_as_test_user
    create_new_form
    create_form_question "Header", nil, "Basic patient info:"
    question_preview_has_header_with_prompt "Basic patient info:"
  end

  def question_preview_has_header_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector ".header"
    end
  end
end
