describe "view and query view" do

  describe "basic functionality" do
    it "displays all responses in a grid" do
      log_in_as_test_user
      create_project_with_form
      enter_responses("FormA", "Enter Name", "Enter date of birth")
      go_to_project_view("ProjectA")
      check_table_dimensions(4, 2)
    end
  end

  describe "filtering" do
    it "filters columns out of grid" do
      log_in_as_test_user
      create_project_with_two_forms
      enter_responses("FormA", "Enter Name", "Enter date of birth")
      enter_alt_responses("FormB", "favorite food", "Enter a date")
      go_to_project_view("ProjectA")
      check_table_dimensions(6, 3)
      filter_grid
      check_table_dimensions(4, 3)
    end
  end
  

  ##
  # need to implement conditional logic still
  ##

  # describe "grid with conditional logic" do
  #   it "turns unreachable cells grey" do
  #     log_in_as_test_user
  #     create_new_form("FormA", "ProjectA")

  #     create_form_question "Text", "var1", "hello"
  #     create_dependent_form_question "Text Field", "var3", "dep_ques", { parents: [question: "hello", logic: '≠', value: 'Bob'] }
  #     enter_dependent_responses("FormA", "hello", "dep_ques")
  #     go_to_project_view
  #     assert_selector("td.grayed", :count => 1)
  #   end
  # end

  describe "grid with identifying info" do
    it "does not display columns with phi data if user has no permission" do
      user_ed = create :user, email: "ed@test.com", first_name: "Ed", last_name: "Mister", password: "Qwerty!1", demo_progress: 6
      log_in_as_test_user
      create_project_with_form
      change_question_to_identifying_info(0)
      enter_responses("FormA", "Enter Name", "Enter date of birth")
      add_team_member
      log_in_as_ed
      go_to_project_view
      check_table_dimensions(3, 2)
    end
  end

  describe "grid with only identifying info" do
    it "shows a message that user does not have permission to view data" do
      user_ed = create :user, email: "ed@test.com", first_name: "Ed", last_name: "Mister", password: "Qwerty!1", demo_progress: 6
      log_in_as_test_user
      create_project_with_form
      change_question_to_identifying_info(0)
      change_question_to_identifying_info(1)
      enter_responses("FormA", "Enter Name", "Enter date of birth")
      add_team_member
      log_in_as_ed
      go_to_project_view
      check_no_grid_display
    end
  end

  describe "no form access" do
    it "shows a message that user has no form access and does not display grid" do
      user_ed = create :user, email: "ed@test.com", first_name: "Ed", last_name: "Mister", password: "Qwerty!1", demo_progress: 6
      log_in_as_test_user
      create_project_with_form
      enter_responses("FormA", "Enter Name", "Enter date of birth")
      add_team_member(false)
      log_in_as_ed
      go_to_project_view
      check_no_grid_display
    end
  end

  describe "no forms in project" do
    it "shows a message that project has no forms" do
      log_in_as_test_user
      visit "/#"
      create_a_project("ProjectA")
      go_to_project_view
      check_no_grid_display
    end
  end

  describe "no questions in project" do
    it "shows a message that there are no questions in the project" do
      log_in_as_test_user
      create_new_form("FormA", "ProjectA")
      go_to_project_view
      check_no_grid_display
    end
  end

  describe "no responses or subjects for project" do
    it "shows a message that there is no data in project" do
      log_in_as_test_user
      create_project_with_form
      go_to_project_view
      check_no_grid_display
    end
  end



  def change_question_to_identifying_info(index)
    question = all('.form-question-container')[index]
      within question do
        find('a', :text => 'Edit').click()
      end
      wait_for_modal_dialog
      within_modal do
        find('label.yes-radio').click()
        click_on "Save Question"
      end
      wait_for_modal_close
  end

  def add_team_member(full_permission_level=true)
     trigger_transition do
        go_to_project("ProjectA")
      end
      trigger_transition do
        page.find('.team-icon').click()
      end
      click_on "Add Team Member"
      wait_for_modal_dialog
      within_modal do
        page.all('.ember-text-field')[0].set('ed@test.com')
        page.all('.ember-text-field')[1].set('11/11/2121')
        selection = page.all('select.ember-select')[0]
        if full_permission_level
          within selection do
            select('Enter/Edit & Build')
          end
        end
        click_on "Add Team Member"
      end
      wait_for_modal_close
  end

  def create_project_with_form(project_name="ProjectA")
    create_new_form("FormA", project_name)
    create_form_question("Date", "var2", "Enter date of birth")
    create_form_question("Text", "var1", "Enter Name")
  end

  def create_project_with_two_forms
    create_new_form("FormA", "ProjectA")
    create_form_question("Date", "var2", "Enter date of birth")
    create_form_question("Text", "var1", "Enter Name")

    trigger_transition do
      go_to_project("ProjectA")
    end

    create_new_form_within_project("FormB")
    create_form_question("Date", "var4", "Enter a date")
    create_form_question("Text", "var3", "favorite food")
  end

  def filter_grid
    assert_selector(".singleFormSelect")
    page.all("input.singleFormSelect")[0].click()
  end

  def enter_responses(form_name, ques1, ques2)
    transition_to_form_view("ProjectA", form_name)
    go_to_response_entry "Patient_1"
    enter_form_data 1, ques1, "Bob"
    enter_form_data 2, ques2, "8/29/1989"
    submit_form_successfully

    go_to_response_entry "Patient_2"
    enter_form_data 1, ques1, "Alice"
    enter_form_data 2, ques2, "08/19/1989"
    submit_form_successfully
    transition_to_form_view("ProjectA", form_name)
  end

  def transition_to_form_view(project="ProjectA", form_name="FormA")
    trigger_transition do
      click_link "Project Home"
    end
    trigger_transition do
      within(page.find(".form-structure-container", :text => form_name)) do
        click_button("Enter/Edit Data")
      end
    end
  end

  def enter_dependent_responses(form_name, ques1, ques2)
    transition_to_form_view("ProjectA", form_name)
    go_to_response_entry "Patient_1"
    enter_form_data 1, ques1, "Bob"
    #enter_form_data 1, ques2, "Bob"
    submit_form_successfully

    go_to_response_entry "Patient_2"
    enter_form_data 1, ques1, "Alice"
    enter_form_data 2, ques2, "08/19/1989"
    submit_form_successfully
    transition_to_form_view("ProjectA", form_name)
  end

  def enter_alt_responses(form_name, ques1, ques2)
    transition_to_form_view("ProjectA", form_name)
    go_to_response_entry "Patient_1"
    enter_form_data 1, ques1, "ice cream"
    enter_form_data 2, ques2, "12/25/1989"
    submit_form_successfully

    go_to_response_entry "Patient_3"
    enter_form_data 1, ques1, "cake"
    enter_form_data 2, ques2, "12/07/1989"
    submit_form_successfully
    transition_to_form_view("ProjectA", form_name)
  end

  def go_to_response_entry(subject_id)
    trigger_transition do
      click_on "Form View"
      fill_in "subjectID", with: "#{subject_id}\n"
    end
  end

  def go_to_project_view(project_name="ProjectA")
    if page.all(".view-data-icon").length == 0
      go_to_project(project_name)
    end
    trigger_transition do
      page.find(".view-data-icon").click()
    end
  end

  def check_table_dimensions(width, height)
    page.assert_selector(".dataTables_scrollHeadInner th.sorting_disabled", :count => width)
    page.assert_selector("#main-data-table tbody tr", :count => height)
  end

  def log_in_as_ed
    ed = User.find_by email: "ed@test.com"
    ed.update_attributes!(password: "Querty!1")
    log_in_as(ed.email, "Querty!1")
  end

  def check_no_grid_display
    sleep 2
    page.assert_selector(".no-data-wrapper")
    page.find("#main-data-table").text.should == ""
  end

end