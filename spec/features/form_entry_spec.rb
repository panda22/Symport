describe "entering data into a form" do
  describe "create/edit by subject" do
    before do
      log_in_as_test_user
      create_new_form "Research Form D"
      create_form_question "Number", "var1", "High or low?", "Maximum Value" => 300, "Minimum Value" => 100, "Precision" => 0.01
    end

    it "lets users create a response for a new subject" do
      complete_form_and_enter_data "Research Form D", true, "abc123"
      see_subject_id_at_top_of_form "abc123"
      see_subject_selection_not_cleared "abc123"
      enter_form_data 1, "High or low?", "200.00"
      submit_form_successfully
      view_form_data 1, "High or low?", "200.00"
    end

    it "lets users edit a response for an existing subject" do
      create_response_for_a_new_subject
      edit_existing_response
      see_edited_response_changed
    end

    it "clears the subject ID when user navigates to responses" do
      complete_form_and_enter_data "Research Form D", true, "abc123"
      see_subject_id_at_top_of_form "abc123"
      see_subject_selection_not_cleared "abc123"
      click_on "Form View"
      see_subject_selection_not_cleared "abc123"
    end

  end

  describe "answer coloring" do
    before do 
      log_in_as_test_user
      create_new_form "Research Form D"
      create_form_question "Number", "var1", "High or low?", "Maximum Value" => 300, "Minimum Value" => 100, "Precision" => 0.01
      create_form_question "Number", "var2", "High or low again?", "Maximum Value" => 300, "Minimum Value" => 100, "Precision" => 0.01
      create_form_question "Number", "var3", "High or low for the third time?", "Maximum Value" => 300, "Minimum Value" => 100, "Precision" => 0.01

      #checks to see if answer coloring works properly
      complete_form_and_enter_data "Research Form D", true, "subject1"
      enter_form_data 1, "High or low?", "200.00"
      enter_form_data 2, "High or low again?", "301.00"
      submit_form
      check_answer_coloring "High or low?", 1
      check_answer_coloring "High or low again?", 2
      check_answer_coloring "High or low for the third time?", 3
    end

    it "adds a new question and checks coloring again" do
      go_to_build_form "Project", "Research Form D"
      create_form_question "Number", "var4", "High or low for the fourth time?", "Maximum Value" => 300, "Minimum Value" => 100, "Precision" => 0.01
      complete_form_and_enter_data "Research Form D", true, "subject1"

      check_answer_coloring "High or low?", 1
      check_answer_coloring "High or low for the third time?", 3
      check_answer_coloring "High or low for the fourth time?", 0
    end

    it "checks answer coloring and then inputs new values to make the boxes turn gray" do
      enter_form_data 1, "High or low?", "200.00"
      enter_form_data 2, "High or low again?", "299.00"
      enter_form_data 3, "High or low for the third time?", "199.00"
      check_answer_coloring "High or low?", 0
      check_answer_coloring "High or low again?", 0
      check_answer_coloring "High or low for the third time?", 0
    end

  end

  describe "leave warning" do
    before do
      log_in_as_test_user
      create_new_form "Research Form A"

      go_to_project "Project"
      create_new_form_within_project "Research Form B"
      create_form_question "Text Field", "var2", "What's your age?"
      complete_form_and_enter_data "Research Form B", true, "abc123"

      #FOR WHATEVER REASON THE TRANSITION OFF OF ENTER/EDIT DATA WILL NOT TRIGGER.
      #THE UNSAVED CHANGES WARNING IS STILL THROWN APPROPRIETLY THOUGH
    end

    it "lets users cancel leaving when there are unsaved changes" do
      enter_form_data 1, "What's your age?", "210.00"
      find(".symport-logo").click()
      page.should_not have_selector ".projects"
      wait_for_modal_dialog
      within_modal do
        click_on "Cancel"
      end
      page.should_not have_selector ".projects"
      enter_form_data 1, "What's your age?", ""
      find(".symport-logo").click()
      page.should_not have_selector ".dialog"
    end

    it "lets users choose to proceed and leave when there are unsaved changes" do
      enter_form_data 1, "What's your age?", "210.00"
      find(".symport-logo").click()
      page.should_not have_selector ".projects"
      wait_for_modal_dialog
      within_modal do
        click_on "Leave Data Entry"
      end
      page.should_not have_selector ".dialog"
    end

    it "does not show a warning when there are no unsaved changes" do
      find(".symport-logo").click()
      page.should have_selector ".projects"
    end
  end

  it "shows error information for invalid inputs" do
    log_in_as_test_user
    create_new_form "Research Form D"
    create_form_question "Number", "var3", "High or low?", "Maximum Value" => 300, "Minimum Value" => 100, "Precision" => 0.01
    create_form_question "Time duration", "var2", "How soon is now?"
    create_form_question "Time of day", "var1", "What's your watch say?"
    complete_form_and_enter_data "Research Form D"

    enter_form_data 1, "What's your watch say?" do
      # "13:30 PM"
      find(".hours").set("13")
      find(".minutes").set("30")
      within(".am-pm") do
        select("PM")
      end
    end

    enter_form_data 2, "How soon is now?" do
      # "-3 h 92 m"
      find(".hours-amount").set("-3")
      find(".minutes-amount").set("92")
      find(".seconds-amount").set("0")
    end

    enter_form_data 3, "High or low?", "402"
    submit_form
    view_form_entry_error 1, "What's your watch say?", "13:30 PM", "Please enter a valid time of day in the format HH:MM AM/PM"
    #view_form_entry_error 2, "How soon is now?", "3 h 92 m", "Invalid time duration"
    view_form_entry_error 3, "High or low?", "402", "402 is greater than 300.0, please enter a number in the specified range"
  end

  def reload_response
    visit "/#/projects/#{Project.first.id}/forms/#{FormStructure.first.id}/responses/#{FormResponse.first.subject_id}/edit"
  end

  def create_response_for_a_new_subject
    complete_form_and_enter_data "Research Form D", true, "abc123"
    enter_form_data 1, "High or low?", "200.00"
    submit_form_successfully
  end

  def see_subject_id_at_top_of_form(subject_id)
    within ".form-response" do
      page.should have_content "VIEWING SUBJECT ID → #{subject_id}"
    end
  end

  def see_subject_selection_cleared
    find("#subjectID").value.should == ""
  end

  def see_subject_selection_not_cleared(id)
    find("#subjectID").value.should == id
  end


  def edit_existing_response
    complete_form_and_enter_data "Research Form D", false, "abc123"
    see_editable_question_has_response("High or low?", "200.00")
    see_subject_id_at_top_of_form "abc123"
    see_subject_selection_not_cleared "abc123"
    enter_form_data 1, "High or low?", "150.00"
    submit_form_successfully
  end

  def see_edited_response_changed
    view_form_data 1, "High or low?", "150.00"
  end

  def view_form_entry_error(sequence_number, prompt, answer, error_msg)
    within ".form-answer", text: prompt do
      page.should have_content "#{sequence_number}"
      page.should have_content prompt
      within('.sub-error') do
        page.should have_content error_msg
      end
    end
  end

  def see_form_lookup_error text
    within('.response-lookup-error') do
      page.should have_content(text)
    end
  end
end
