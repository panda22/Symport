describe "renaming projects and forms" do

  before do
    log_in_as_test_user
  end

  it "allows users to rename projects" do
    visit_home_page
    create_a_project "The TTP Project"
    successfully_rename_project_to "The TTP Project", "Alan Parsons Project"
    see_project "Alan Parsons Project"
  end

  it "disallows users from renaming projects to a project with the NO name" do
    create :project_a
    visit_home_page
    create_a_project "The TTP Project"
    fail_to_rename_project_to_nothing "The TTP Project"
  end

  it "allows users to rename forms" do
    #create :response_research_form_a
    visit_home_page
    create_a_project "Project Name"
    visit_home_page
    create_another_form_in "Research Form A", "Project Name"
    return_to_project_page ("Project Name")
    create_another_form_in "Research Form C", "Project Name"
    return_to_project_page ("Project Name")
    successfully_rename_form "Research Form A", "Research Form Z"
    see_forms ["Research Form C", "Research Form Z"]
  end

  it "prevents users from renaming a form with an existing name" do
    #create :response_research_form_a
    visit_home_page
    create_a_project "Project Name"
    visit_home_page
    create_another_form_in "Research Form A", "Project Name"
    return_to_project_page ("Project Name")   
    create_another_form_in "Research Form C", "Project Name"
    return_to_project_page ("Project Name")
    fail_to_rename_form "Research Form A", "Research Form C"
  end

  def create_another_form_in (new_form_name, projectName)
    find(".clickable-project-container", text: projectName).click
    create_new_form_within_project new_form_name
  end

  def rename_form(old_name, new_name)
    in_project_form old_name do
      find(".form-structure-links>a").hover()
      sleep 1
      find("a.rename").click()
    end
    wait_for_modal_dialog
    within ".dialog" do
      find(".form-name").set new_name
      click_button "Save"
      sleep 1
    end
  end

  def successfully_rename_form(old_name, new_name)
    rename_form old_name, new_name
    wait_for_modal_close
    page.should_not have_content "Rename your form below"
  end

  def fail_to_rename_form(old_name, new_name)
    rename_form old_name, new_name
    within_modal do
      current_scope.should have_content "Please make your form name unique"
    end
  end

  def visit_home_page
    visit "/#"
  end

  def rename_project_to(old_name, new_name)
    visit "/#/projects"
    visit "/#/projects"
    within ".clickable-project-container", text: old_name do
      find(".project-links>a").hover()
      sleep 1
      find("a.rename").click()
    end
    wait_for_modal_dialog
    within_modal do
      find(".project-name").set(new_name)
      click_button "Save"
      sleep 1
    end
  end

  def successfully_rename_project_to(old_name, new_name)
    rename_project_to old_name, new_name
    wait_for_modal_close
    page.should_not have_content "Rename your project below"
  end

  def fail_to_rename_project_to_nothing(old_name)
    rename_project_to old_name, ""
    within_modal do
      current_scope.should have_content "Please name your project"
    end
  end

end
