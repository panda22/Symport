describe "preview a form" do

  it "shows a form preview" do
    log_in_as_test_user
    create_new_form "Research Form D"
    create_form_question "Text Field", "var1", "What's your name?"
    create_form_question "Date Field", "var2", "What day is it?"
    create_form_question "Number", "var3", "How old are you?", "Maximum Value" => 100, "Minimum Value" => 18, "Minimum Precision" => "Whole numbers only"
    jump_to_preview

    preview_form_data 3, "What's your name?"
    preview_form_data 2, "What day is it?"
    preview_form_data 1, "How old are you?"
  end

  def jump_to_preview
    click_link "Preview Form"
  end

  def preview_form_data(sequence_number, prompt)
    within ".form-answer", text: prompt do
      page.should have_content "#{sequence_number}"
      page.should have_content prompt
    end
  end
end
