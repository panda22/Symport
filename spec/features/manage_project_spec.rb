describe "managing a project" do

  before do
    log_in_as_test_user
  end

  it "allows users to create a new project" do
    create_new_project "My Cool Project"
    create_new_form_within_project "Test Form 1"
    return_to_project_page "My Cool Project"
    create_new_form_within_project "Test Form 2"
    return_to_project_page "My Cool Project"
    see_forms ["Test Form 1", "Test Form 2"]
  end

  it "allows users to delete a form from a project" do
    struc = create :structure_research_form_a
    go_to_project "Project A"
    delete_form "Research Form A"
    see_no_forms
  end

  it "allows users to update an existing form for a project" do
    create :structure_research_form_a
    go_to_project "Project A"
    edit_form "Research Form A"
    create_form_question "Text Field", "var1", "Who was I?"
    complete_form_and_enter_data "Research Form A"
  end

  it "allows users to enter new data for a form in a project" do
    create_project_with_responses
    add_a_new_response
    see_changed_response_count
  end

  it "allows users to delete a project" do
    #create_project_with_responses
    #delete_project "Project B"
    #refresh_and_see_no_project "Project B"
    # DELETE HAS BEEN MOVED OFF THE PROJECT BOXES IN MY PROJECTS. IT WILL MOVE TO THE DEDICATED PROJECT SETTINGS PAGE
  end

  def delete_project(project_name)
    visit "/#"
    within ".project-container", text: project_name do
      click_on "Delete"
    end
    wait_for_modal_dialog
    within_modal do
      click_on "Delete Project"
    end
    wait_for_modal_close
  end

  def refresh_and_see_no_project(project_name)
    visit "/#"
    page.should_not have_selector ".project", text: project_name
  end

  def create_project_with_responses
    create :response_research_form_b
  end

  def add_a_new_response
    go_to_project "Project B"
    see_response_count_for_form "Research Form B", 1
    edit_form "Research Form B"
    complete_form_and_enter_data "Research Form B"
    enter_form_data 1, "Name:", "Doctor Who"
    enter_form_data 2, "Age", "51"
    enter_form_data 3, "Date of birth", "04/29/2014"
    enter_form_data 4, "Checking the clock" do
      # "13:30 PM"
      find(".hours").set("3")
      find(".minutes").set("30")
      within(".am-pm") do
        select("PM")
      end
    end
    submit_form_successfully
  end

  def see_changed_response_count
    go_to_project "Project B"
    see_response_count_for_form "Research Form B", 2
  end


end
