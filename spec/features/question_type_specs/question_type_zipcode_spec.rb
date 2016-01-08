describe "creating a zipcode question" do
  before do
    log_in_as_test_user
    create_new_form
  end

  it "allows users to create zipcode question with a prompt" do
    create_form_question "Zipcode", "var1", "Location, Location:"
    complete_form_and_enter_data
    question_preview_has_zipcode_with_prompt "Location, Location:"
  end

  it "allows users to create a question that depends on a yes-no value" do
    create_form_question "Zipcode", "var1", "Where?"

    create_dependent_form_question "Text Field", "var3", "Have you never been mellow?", { parents: [question: "Where?", logic: '≠', value: '90210'] }
    complete_form_and_enter_data
    enter_form_data 1, "Where?", "55555"
    question_should_not_be_grayed_out 2, "Have you never been mellow?"
    enter_form_data 1, "Where?", "90210"
    question_should_be_grayed_out 2, "Have you never been mellow?"
  end

  def question_preview_has_zipcode_with_prompt(prompt)
    question_preview_has_content prompt do
      page.should have_selector "input.zipcode"
      validate_zip_codes
    end
  end

  def validate_zip_codes
    fill_zip "12345"
    find(".zipcode").value.should == "12345"

    fill_zip "123"
    find(".zipcode").value.should == "123"

    fill_zip "Apple"
    find(".zipcode").value.should == ""

    fill_zip "1234567"
    find(".zipcode").value.should == "12345"
  end

  def fill_zip(some_text)
    find(".zipcode").set some_text
    find(".zipcode").trigger "blur"
  end
end
