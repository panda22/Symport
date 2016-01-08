describe "manage form permissions" do
  before do
    create_a_project_and_team
    create_forms_and_permissions
    go_to_team_page
  end

  it "shows the permissions for each form" do
    see_form_permissions
  end

  it "allows user to update permission level" do
    update_permission_for("Jon Schmidt", "Formica", "View Data")
    see_user_permission_changed("Jon Schmidt", "Formica", "View Data")
  end

  private def open_team_member(full_name)
    within ".team-member", text: full_name do
      find("a", text: "View and Edit").click()
    end
    wait_for_modal_dialog
  end

  def update_permission_for(full_name, form_name, permission_level)
    open_team_member full_name
    within ".form-permission", text: form_name do
      within ".permission-level" do
        select permission_level
      end
    end

    click_on "Save"
    wait_for_modal_close
  end

  def see_user_permission_changed(full_name, form_name, permission_level)
    open_team_member full_name
    see_form_permission(form_name, permission_level)
    click_on "Cancel"
    wait_for_modal_close
  end

  def create_forms_and_permissions
    project = Project.first
    first_form = FormStructure.create(name: "Formica")
    second_form = FormStructure.create(name: "Formalise")
    project.form_structures << first_form
    project.form_structures << second_form
    project.save!

    team_members = project.team_members
    jon = team_members.joins(:user).find_by(users: {email:"jon@test.com"})
    ed = team_members.joins(:user).find_by(users: {email:"ed@test.com"})
    tim = team_members.joins(:user).find_by(users: {email:"tim@test.com"})

    form_permission_1 = FormStructurePermission.create(team_member: jon, permission_level: "Full")
    form_permission_2 = FormStructurePermission.create(team_member: ed, permission_level: "Read")
    first_form.form_structure_permissions << form_permission_1
    first_form.form_structure_permissions << form_permission_2

    form_permission_3 = FormStructurePermission.create(team_member: tim, permission_level: "Read/Write")
    form_permission_4 = FormStructurePermission.create(team_member: ed, permission_level: "Full")
    second_form.form_structure_permissions << form_permission_3
    second_form.form_structure_permissions << form_permission_4
  end

  def see_form_permissions
    open_team_member "Jon Schmidt"
    see_form_permission "Formica", "Enter/Edit & Build"
    see_form_permission "Formalise", "No Access"
    click_on "Cancel"
    wait_for_modal_close

    open_team_member "Ed Mister"
    see_form_permission "Formica", "View Data"
    see_form_permission "Formalise", "Enter/Edit & Build"
    click_on "Cancel"
    wait_for_modal_close

    # admin's are always Full
    open_team_member "Tim Dood"
    see_form_permission "Formica", "Enter/Edit & Build"
    see_form_permission "Formalise", "Enter/Edit & Build"
    click_on "Cancel"
    wait_for_modal_close
  end

  def see_form_permissions_count(count)
    FirePoll.poll do
      all(".form-permission").count == count
    end
  end

  def see_form_permission(form_name, permission_level)
    within ".form-permission", text: form_name do
      find("td:nth-of-type(2)").should have_content permission_level
    end
  end
end
