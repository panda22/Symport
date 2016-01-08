describe "creating a Number question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create Number question with a prompt" do
    create_form_question "Number", "var1", "Whatever:", "Minimum Value" => 10, "Maximum Value" => 100, "Precision" => 0.01
    complete_form_and_enter_data
    question_preview_has_numerical_range_with_prompt "Whatever:"
  end

  it "allows users to create a question dependent on Number value" do
    create_form_question "Number", "var1", "Whatever:", "Minimum Value" => 10, "Maximum Value" => 100, "Precision" => 0.01

    create_dependent_form_question "Text Field", "var2", "Have you ever been pregnant?", { parents: [question: "Whatever:", logic: '<', value: '20.00'] }
    complete_form_and_enter_data
    enter_form_data 1, "Whatever:", "15"
    question_should_not_be_grayed_out 2, "Have you ever been pregnant?"
    enter_form_data 1, "Whatever:", "25"
    question_should_be_grayed_out 2, "Have you ever been pregnant?"
  end

  def question_preview_has_numerical_range_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector "input.number-entry"
      validate_numerical_range
    end
  end

  def enter_number_range_min number
    find(".min-range").set number
  end

  def enter_number_range_max number
    find(".max-range").set number
  end

  def enter_number_range_precision number
    within ".precision" do
      select number
    end
  end

  def validate_numerical_range
    fill_number "1.5"
    find(".number-entry").value.should == "1.5"

    fill_number "123"
    find(".number-entry").value.should == "123"

    fill_number "Apple"
    find(".number-entry").value.should == ""

    fill_number "112.345676"
    find(".number-entry").value.should == "112.345676"

    fill_number ".112545676"
    find(".number-entry").value.should == ".112545676"
  end

  def fill_number(some_text)
    find(".number-entry").set ""
    find(".number-entry").trigger "blur"

    find(".number-entry").set some_text
    find(".number-entry").trigger "blur"
  end
end
