describe "permissions filtering" do
  let (:password) { "Passw0rd" }
  let (:admin_user) { create :user, email: "admin@test.com", password: password, demo_progress: 6 }
  let (:form_creating_user) { create :user, email: "creation@test.com", password: password, demo_progress: 6  }
  let (:exporting_user) { create :user, email: "export@test.com", password: password, demo_progress: 6  }
  let (:phi_user) { create :user, email: "phi@test.com", password: password, demo_progress: 6  }
  let (:member_only_user) { create :user, email: "member@test.com", password: password, demo_progress: 6  }
  before do
    create_project_and_form_for_permissions_checks
  end

  context "project home page" do
    context "project settings" do
      it "allows access to project settings when user has permissions" do
        log_in_perm_user admin_user
        #go_to_test_project_home
        see_project_link "Permissions Project", "Rename Project"
      end

      it "does not allow access to project settings when user lacks permissions" do
        log_in_perm_user form_creating_user
        #go_to_test_project_home
        see_disabled_project_link "Permissions Project", "Rename Project"
      end
    end

    context "create form" do
      it "allows access to form creation when user has permissions" do
        log_in_perm_user form_creating_user
        go_to_test_project_home
        see_button_enabled "Create a New Form"
      end

      it "does not allow access to form creation when user lacks permissions" do
        log_in_perm_user exporting_user
        go_to_test_project_home
        see_button_disabled "Create a New Form"
      end
    end

    context "view and enter data" do
      it "restricts access by form permissions" do
        log_in_perm_user member_only_user
        go_to_test_project_home
        see_form_button_enabled "First Form", "Enter/Edit Data"
        see_form_button_disabled "Second Form", "Enter/Edit Data"
      end
    end

    context "renaming forms" do
      it "allows access for form creating users" do
        log_in_perm_user form_creating_user
        go_to_test_project_home
        see_form_link "First Form", "Rename"
        see_form_link "Second Form", "Rename"
      end

      it "rejects access for non-admin, non-form-creating users" do
        log_in_perm_user exporting_user
        go_to_test_project_home
        see_disabled_form_link "First Form", "Rename"
        see_disabled_form_link "Second Form", "Rename"
      end
    end

    context "deleting forms" do
      it "restricts access by form permissions" do
        log_in_perm_user admin_user
        go_to_test_project_home
        see_form_link "First Form", "Delete"
        see_form_link "Second Form", "Delete"
      end

      it "rejects access for non-admins" do
        log_in_perm_user member_only_user
        go_to_test_project_home
        see_disabled_form_link "First Form", "Delete"
        see_disabled_form_link "Second Form", "Delete"
      end
    end
    
    context "building forms" do
      it "restricts access by form permissions" do
        log_in_perm_user form_creating_user
        go_to_test_project_home
        see_form_button_disabled "First Form", "Build Form"
        see_form_button_enabled "Second Form", "Build Form"
      end
    end

    context "downloading data" do
      it "allows downloading data when user has permissions" do
        log_in_perm_user exporting_user
        go_to_test_project_home
        see_form_button_enabled "First Form", "Download Data"
        see_form_button_enabled "Second Form", "Download Data"
      end

      it "does not allow downloading data when user lacks permissions" do
        log_in_perm_user form_creating_user
        go_to_test_project_home
        see_form_button_disabled "First Form", "Download Data"
        see_form_button_disabled "Second Form", "Download Data"
      end
    end
  end

  context "view and enter data" do
    context "entering data" do
      it "allows entering data if user has permissions" do
        log_in_perm_user admin_user
        go_to_form_grid_page_with_full_permissions "First Form"
        click_on "Form View"
        fill_in "subjectID", with: "a"
        within ".combo-box" do
          page.should have_content "+ Create New"
        end
      end

      it "prevents entering data if user lacks permissions" do
        log_in_perm_user exporting_user
        go_to_form_grid_page_with_some_permissions "First Form"
        page.should have_link "Form View"
        click_on "Form View"
        fill_in "subjectID", with: "a"
        within ".combo-box" do
          page.should_not have_content "+ Create New"
        end
      end
    end
  end

  context "team management" do
    context "adding team members" do
      it "allows adding and removing team members if user has permissions" do
        log_in_perm_user admin_user
        go_to_test_project_team_page
        see_button_enabled "Add Team Member"
        all("a", text: "Remove").length.should_not == 0
      end

      it "prevents adding and removing team members if user lacks permissions" do
        log_in_perm_user form_creating_user
        go_to_test_project_team_page
        see_button_disabled "Add Team Member"
        page.should_not have_link "Remove"
      end

      it "allows editing team members if user has permissions" do
        log_in_perm_user admin_user
        go_to_test_project_team_page
        sleep 1
        all("a", text: "View and Edit").length.should_not == 0
      end

      it "prevents editing team members if user lacks permissions" do
        log_in_perm_user form_creating_user
        go_to_test_project_team_page
        page.should_not have_link "View and Edit"
      end
    end
  end

  def create_project_and_form_for_permissions_checks
    project = Project.create! name: "Permissions Project"
    admin_member = TeamMember.create user: admin_user, administrator: true
    form_creating_member = TeamMember.create user: form_creating_user, form_creation: true
    exporting_member = TeamMember.create user: exporting_user, export: true
    phi_member = TeamMember.create user: phi_user, view_personally_identifiable_answers: true
    member_only_member = TeamMember.create user: member_only_user
    project.team_members = [ admin_member, form_creating_member, exporting_member, phi_member, member_only_member ]
    project.save!

    first_form = FormStructure.create! name: "First Form", project: project
    second_form = FormStructure.create! name: "Second Form", project: project

    first_form.form_structure_permissions << FormStructurePermission.create(team_member: form_creating_member, permission_level: "Read/Write")
    first_form.form_structure_permissions << FormStructurePermission.create(team_member: exporting_member, permission_level: "Read")
    first_form.form_structure_permissions << FormStructurePermission.create(team_member: phi_member, permission_level: "Full")
    first_form.form_structure_permissions << FormStructurePermission.create(team_member: member_only_member, permission_level: "Full")
    first_form.save!

    second_form.form_structure_permissions << FormStructurePermission.create(team_member: form_creating_member, permission_level: "Full")
    second_form.form_structure_permissions << FormStructurePermission.create(team_member: exporting_member, permission_level: "Full")
    second_form.form_structure_permissions << FormStructurePermission.create(team_member: phi_member, permission_level: "Full")
    second_form.form_structure_permissions << FormStructurePermission.create(team_member: member_only_member, permission_level: "None")
    second_form.save!
  end

  def go_to_test_project_home
    go_to_project "Permissions Project"
  end

  def go_to_test_project_team_page
    go_to_test_project_home
    within ".side-nav" do
      trigger_transition do
        click_on "Team"
      end
    end
  end

  def go_to_form_grid_page_with_full_permissions(form_name)
    go_to_test_project_home
    in_project_form form_name do
      trigger_transition do
        click_on "Enter/Edit Data"
      end
    end
  end

  def go_to_form_grid_page_with_some_permissions(form_name)
    go_to_test_project_home
    in_project_form form_name do
      trigger_transition do
        click_on "View Form Data"
      end
    end
  end
    
  def see_button_enabled(button_text)
    find_button(button_text, disabled: false)
  end

  def see_button_disabled(button_text)
    find_button(button_text, disabled: true)
  end

  def see_form_button_enabled(form_name, button_text)
    in_project_form form_name do
      see_button_enabled button_text
    end
  end

  def see_form_button_disabled(form_name, button_text)
    in_project_form form_name do
      see_button_disabled button_text
    end
  end

  def see_project_link(project_name, link_text)
    within ".clickable-project-container", text: project_name do
      find(".project-links>a").hover()
      sleep 1
      find("a", text: "Rename Project")['class'].should == "rename right"
    end
  end

  def see_disabled_project_link(project_name, link_text)
    within ".clickable-project-container", text: project_name do
      find(".project-links>a").hover()
      sleep 1
      find("a", text: "Rename Project")['class'].should == "rename right notAdmin"
    end
  end

  def see_form_link(form_name, link_text)
    in_project_form form_name do
      find(".form-structure-links>a").hover()
      sleep 1
      find("a", text: link_text)
    end
  end

  def see_disabled_form_link(form_name, link_text)
    in_project_form form_name do
      find(".form-structure-links>a").hover()
      sleep 1
      find("a.disabled", text: link_text)
    end
  end

  def log_in_perm_user user
    log_in_as user.email, password
  end

end
