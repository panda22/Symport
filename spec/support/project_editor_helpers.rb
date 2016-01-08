module ProjectEditorHelpers
  def create_new_project(project_name="Temp")
    visit "/#"
    click_on "Create New Project"
    within_modal do
      find(".project-name").set project_name
      click_on "Create"
    end
  end

  def return_to_project_page(name)
    sleep 1
    visit "/#/projects"
    visit "/#/projects"
    page.should have_content "Projects"
    find(".clickable-project-container", text: name).click
  end

  def see_projects(project_names)
    project_names.each do |name|
      page.should have_content name
    end
  end

  def see_project(project_name)
    see_projects [project_name]
  end

  def see_forms(form_names)
    form_names.each do |name|
      page.should have_content name
    end
  end

  def see_no_forms
    page.should_not have_selector ".form-structure-container"
  end

  def edit_form(name="Temp")
    project = Project.first
    form = FormStructure.find_by name: name
    visit "/#/projects/#{project.id}/forms/#{form.id}/build"
    visit "/#/projects/#{project.id}/forms/#{form.id}/build"
    sleep(2)
    # in_project_form name do
    click_on "Edit Form"
    # end
  end


  def delete_form(form_name, wait_for_close=true)
    sleep 3
    in_project_form form_name do
      find(".form-structure-links>a").hover()
      sleep 1
      find("a.delete").click()
    end
    wait_for_modal_dialog
    within ".dialog" do
      find("input").set("DELETE")
      click_button "Delete"
    end
    if wait_for_close
      wait_for_modal_close
    end
  end

  def in_project_form(form_name)
    within ".form-structure-container", text: form_name do
      yield
    end
  end

  def go_to_project(project_name)
    visit "/#"
    visit "/#"
    find(".clickable-project-container", text: project_name).click()
  end

  def go_to_form_responses(project_name="ProjectA", form_name="FormA")
    visit root_path
    trigger_transition do
      go_to_project(project_name)
    end

    trigger_transition do
      in_project_form(form_name) do
        find(".button", text: "Enter/Edit Data").click()
      end
    end
    #find("a", text: "Grid View").click()
    #page.should have_content "Form View"
  end

  def go_to_form_view(project_name="ProjectA", form_name="FormA")
    visit root_path
    trigger_transition do
      go_to_project(project_name) 
    end

    trigger_transition do
      in_project_form(form_name) do
        click_on "Enter/Edit Data"
      end
      click_on "Form View"
    end
    page.should have_content "Enter data into - #{form_name}"
  end

  def go_to_build_form(project_name="ProjectA", form_name="FormA")
    visit root_path
    trigger_transition do
      go_to_project(project_name) 
    end

    trigger_transition do
      in_project_form(form_name) do
        click_on "Build Form"
      end
    end
    page.should have_content "#{form_name}"
  end


  def create_a_project_and_team
    project = create :project_a
    user_bob = create :user, email: "bob@test.com", password: "Complex1", first_name: "Bob", last_name: "Guy", demo_progress: 6, phone_number: "1234567890"
    user_tim = create :user, email: "tim@test.com", password: "Complex1", first_name: "Tim", last_name: "Dood", demo_progress: 6, phone_number: "1234567890"
    user_ed = create :user, email: "ed@test.com", password: "Complex1", first_name: "Ed", last_name: "Mister", demo_progress: 6, phone_number: "1234567890"
    user_jon = create :user, email: "jon@test.com", password: "Complex1", first_name: "Jon", last_name: "Schmidt", demo_progress: 6, phone_number: "1234567890"
    project.team_members << TeamMember.create!(user: user_tim, administrator: true, expiration_date: Date.parse("Oct 24, 2020"))
    project.team_members << TeamMember.create!(user: user_ed, form_creation: true, expiration_date: Date.parse("Jan 4, 2020"))
    project.team_members << TeamMember.create!(user: user_jon, audit: true, export: true, expiration_date: Date.parse("Jan 1, 2012"))
    project.save!
  end

  def go_to_team_page(project_name="Project A")
    log_in_as_test_user
    go_to_project project_name
    within ".side-nav" do
      click_on "Team"
    end
    sleep 2
  end

  alias_method :edit_project, :go_to_project

  def create_a_project(name)
    open_modal "Create New Project"
    within_modal do
      find(".project-name").set(name)
      click_button "Create"
    end
    wait_for_modal_close
  end

  def see_response_count_for_form(form_name, response_count)
    in_project_form form_name do
      within ".entries" do
        page.should have_content response_count
      end
    end
  end
end
