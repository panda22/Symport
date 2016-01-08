describe "creating a dropdown question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create dropdown question with a prompt" do
    preview_form_question "Dropdown", "var1", "One of these:" do
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end
    question_preview_has_datalist_with_prompt "One of these:"
  end

  it "allows users to create a question dependent on dropdown value" do
    create_form_question "Dropdown", "var2", "One of these:" do
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end
    go_to_project "Project"
    find("button", text: "Build Form").click()
    create_dependent_form_question "Text Field", "var3", "Have you ever been pregnant?", { parents: [question: "One of these:", logic: '=', value: 'Pop'] }
    complete_form_and_enter_data
    enter_form_data 1, "One of these:", "Pop"
    within ".form-answer", text: "Have you ever been pregnant?" do
      find("textarea", visible: false)['disabled'].should == false
    end
    question_should_not_be_grayed_out 2, "Have you ever been pregnant?"
    enter_form_data 1, "One of these:", "Snap"
    within ".form-answer", text: "Have you ever been pregnant?" do
      find("textarea", visible: false)['disabled'].should == true
    end
    question_should_be_grayed_out 2, "Have you ever been pregnant?"
  end

  def question_preview_has_datalist_with_prompt(prompt)
    question_preview_has_content prompt do
      within ".drop-down-wrapper" do
        find(".drop-down-input").value.should == "Please Select..."
      end
      has_option "Snap"
      has_option "Crackle"
      has_option "Pop"
    end
  end

  def has_option(option_text)
    find(".option", text: option_text, visible: false) 
  end
end
