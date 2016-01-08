describe "building a form" do
    before do
        log_in_as_test_user
    end

  it "supports building a form and entering data" do
    create_new_form "Research Form C"
    create_form_question "Zipcode", "var3", "Where am I?"
    create_form_question "Date Field", "var2", "What day is it?"
    create_form_question "Text Field", "var1", "Who am I?"
    complete_form_and_enter_data "Research Form C"
    enter_form_data 1, "Who am I?", "Doctor Who"
    enter_form_data 2, "What day is it?", "04/29/2014"
    enter_form_data 3, "Where am I?", "49506"
    submit_form_successfully

    view_form_data 1, "Who am I?", "Doctor Who"
    view_form_data 2, "What day is it?", "04/29/2014"
    view_form_data 3, "Where am I?", "49506"
  end

  it "doesn't create a question with the same variable name of a former question on the form" do
    create_new_project "Project1"
    create_new_form_within_project "Test Form 1"
    create_form_question "Text Field", "var1", "Who am I?"
    return_to_project_page "Project1"

    go_to_project "Project1"
    create_new_form_within_project "Test Form 2"
    start_form_question "Text Field", "var1", "Who are you?"
    click_button "Save and Add Question"
    page.should have_content("The variable name is the same as another question's variable name, please make it unique")
  end

  it "supports building a form combining conditional and non-conditional questions - criteria for dependent question doesn't meet" do
    create_new_form "Cool Conditional Form"
    create_form_question "Text Field", "var1", "Are you male or female?"
    create_dependent_form_question "Text Field", "var2", "Have you ever been pregnant?", { "Description" => 'foo', parents: [question: "Are you male or female?", logic: '=', value: 'female'] }
    create_form_question "Text Field", "var3", "How old are you?"

    complete_form_and_enter_data "Cool Conditional Form"
    view_conditional_logic_label 2, "Are you male or female", "Used in Conditional Logic"
    view_conditional_logic_label 3, "Have you ever been pregnant", "Shown Based on Conditional Logic"
    enter_form_data 2, "Are you male or female?", "male"
    question_should_be_grayed_out 3, "Have you ever been pregnant?"
    enter_form_data 1, "How old are you?", "15"
    submit_form_successfully

    view_form_data 2, "Are you male or female?", "male"
    view_form_data_grayed_out 3, "Have you ever been pregnant?"
    view_form_data 1, "How old are you?", "15"
  end

  it "supports building a form combining conditional and non-conditional questions - criteria for dependent question meet" do
    create_new_form "Cool Conditional Form"
    create_form_question "Text Field", "var1", "Are you male or female?"
    create_dependent_form_question "Text Field", "var2", "Have you ever been pregnant?", { parents: [question: "Are you male or female?", logic: '=', value: 'female'] }
    create_form_question "Text Field", "var3", "How old are you?"

    complete_form_and_enter_data "Cool Conditional Form"
    view_conditional_logic_label 1, "Are you male or female", "Used in Conditional Logic"
    view_conditional_logic_label 3, "Have you ever been pregnant", "Shown Based on Conditional Logic"
    enter_form_data 2, "Are you male or female?", "female"
    enter_form_data 3, "Have you ever been pregnant?", "Yes"
    enter_form_data 1, "How old are you?", "15"
    submit_form_successfully

    view_form_data 2, "Are you male or female?", "female"
    view_form_data 3, "Have you ever been pregnant?", "Yes"
    view_form_data 1, "How old are you?", "15"
  end


end
