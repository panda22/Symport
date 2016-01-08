describe "creating a text question" do

  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create a long text question with a prompt" do
    preview_form_question "Text Field", "var1", "Long long long:"
    question_preview_has_text_with_prompt(:long, "Long long long:")
  end

  it "allows users to create a question that depends on a text value" do
    create_form_question "Text Field", "var1", "Free text:"

    create_dependent_form_question "Text Field", "var3", "Have you never been mellow?", { parents: [question: "Free text:", logic: '≠', value: 'Grease'] }
    complete_form_and_enter_data
    enter_form_data 1, "Free text:", "Lightning"
    question_should_not_be_grayed_out 2, "Have you never been mellow?"
    enter_form_data 1, "Free text:", "Grease"
    question_should_be_grayed_out 2, "Have you never been mellow?"
  end

  def question_preview_has_text_with_prompt(type, prompt, description=nil)
    question_preview_has_content prompt, description do
      if type == :short
        page.should have_selector "input"
      else
        page.should have_selector "textarea"
      end
    end
  end
end
