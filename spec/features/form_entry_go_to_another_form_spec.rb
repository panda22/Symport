describe "go to another form" do
  before do
    log_in_as_test_user
    create_new_form "Research Form A"
    create_form_question "Text Field", "var1", "What's your name?"

    go_to_project "Project"
    create_new_form_within_project "Research Form B"
    create_form_question "Text Field", "var2", "What's your age?"

    go_to_project "Project"
    create_new_form_within_project "Research Form C"
    create_form_question "Text Field", "var3", "Where are you living?"
  end

  it "allows users to go to another form entry for the same subject from current response" do
    complete_form_and_enter_data "Research Form A", true, "abc123"
    see_other_selectable_forms(["Research Form B", "Research Form C"])

    switch_form("Research Form B")

    see_that_the_current_form_is("Research Form B")
    see_the_subject_id_is_the_same_subject_id("abc123")
    enter_form_data 1, "What's your age?", "20"
    see_other_selectable_forms(["Research Form A", "Research Form C"])

  end

  it "allows users to go to another form entry for the same subject from current response with changed data" do
    complete_form_and_enter_data "Research Form A", true, "abc123"
    enter_form_data 1, "What's your name?", "John"
    see_other_selectable_forms(["Research Form B", "Research Form C"])

    switch_form("Research Form B")
    within_modal do
      click_on "Cancel"
    end
    see_that_the_current_form_is("Research Form A")

    switch_form("Research Form B")
    within_modal do
      click_on "Leave Data Entry"
    end
    see_that_the_current_form_is("Research Form B")
    see_the_subject_id_is_the_same_subject_id("abc123")

    see_other_selectable_forms(["Research Form A", "Research Form C"])

  end

  def see_other_selectable_forms(form_names)
    within "#go-to-form" do
      opts = all("option").map(&:text)
      form_names.each do |name| 
        opts.should include(name) 
      end
    end
  end

  def switch_form(form_name)
    select(form_name, :from => 'go-to-form')
  end

  def see_that_the_current_form_is(form_name)
    within '.instructions' do
      page.should have_content(form_name)
    end
  end

  def see_the_subject_id_is_the_same_subject_id(subject_id)
    within ".current-subject" do
      page.should have_content subject_id
    end
    # within '.specify-subject-box' do
    #   expect(page).to have_select('subjectID', selected: subject_id)
    # end
  end

end
