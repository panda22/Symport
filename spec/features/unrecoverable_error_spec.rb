describe "unrecoverable error" do
  it "sends users back to My Projects" do
    begin_creating_a_form
    form_gets_deleted_while_creating_a_question
    see_redirected_on_failure
  end

  def begin_creating_a_form
    log_in_as_test_user
    create_new_form "Research Form C", "Project A"
    sleep 1
    return_to_project_page "Project A"
  end

  def form_gets_deleted_while_creating_a_question
    #start_form_question "Text Field", "var2", "Not Gonna Do It"
    # remove record underneath user
    page.should have_content "Research Form C"
    FormStructure.find_by(name: "Research Form C").destroy
    page.should have_content "Research Form C"
    delete_form "Research Form C", false

    #click_button "Save and Add Question"
  end

  def see_redirected_on_failure
    page.should have_content "You will be redirected back to 'My Projects'."
    within_modal do
      click_button "OK"
    end
    sleep 1
    # back to My Projects
    within ".projects" do
      page.should have_content "Project A"
    end
  end
end
