describe "manage a project's team" do
  before do
    Timecop.travel Time.local(2014, 7, 3, 15, 10) # Jul 3, 2014
    create_a_project_and_team
  end

  after do
    Timecop.return
  end

  it "shows the members of a team" do
    go_to_team_page
    see_team_members_and_permissions
  end

  it "prevents user from removing themselves as admin" do
    log_in_as_tim_user
    visit_team_page
    remove_user_from_project "Tim Dood" #Tim Dood is the user logged in to the system. He's an Admin.
    see_error_message "Team member tim@test.com may not be deleted because they are the only administrator"
  end

  it "allows user to add an admin team member" do
    user_dave = create :user, email: "dave@test.com", password: "Complex1", first_name: "Dave", last_name: "Qorashi"

    go_to_team_page
    click_on "Add Team Member"
    fill_in('Email', :with => user_dave.email)
    within "label", text: "Set User As Admin" do
      choose('Yes')
    end
    within ".dialog" do
      click_on "Add Team Member"
    end
    wait_for_modal_close
    team_member_index_page_should_include "Dave Qorashi"
  end

  it "allows user to add a non-admin team member" do
    user_dave = create :user, email: "dave@test.com", password: "Complex1", first_name: "Dave", last_name: "Qorashi"

    go_to_team_page
    click_on "Add Team Member"

    fill_in('Email', :with => user_dave.email)
    fill_in('Expiration Date', :with => '08/3/2015')
    
    within "label", text: "Set User As Admin" do
      choose('No')
    end

    within "label", text: "Form Creation" do
      choose('Yes')
    end

    within "label", text: "View Identifying Information" do
      choose('Yes')
    end

    within ".dialog" do
      click_on "Add Team Member"
    end
    wait_for_modal_close
    team_member_index_page_should_include "Dave Qorashi"
    team_member_should_have_the_permissions_saved "Dave Qorashi"
  end

  it "allows user to delete team members" do
    log_in_as_tim_user
    visit_team_page
    remove_user_from_project "Jon Schmidt"
    team_member_index_page_should_not_include "Jon Schmidt"
  end

  def team_member_should_have_the_permissions_saved name
    within ".team-member", text: name do
      find("a", text: "View and Edit").click()
    end

    within "label", text: "Form Creation" do
      find(".yes-radio input").should be_checked
    end

    within "label", text: "View Identifying Information" do
      find(".yes-radio input").should be_checked
    end

    #within ".permission-audit-log .radio-option-yes"  do
    #  find(".ember-radio-button").should_not be_checked
    #end

    within "label", text: "Download Data" do
      find(".yes-radio input").should_not be_checked
    end
  end

  def team_member_index_page_should_include name
    within ".grid-container" do
      page.current_scope.should have_content name
    end
  end

  def team_member_index_page_should_not_include name
    within ".grid-container" do
      page.should_not have_content name
    end
  end

  def log_in_as_tim_user
    user = User.find_by(email: "tim@test.com")
    user.password = "Nope1234"
    user.save!
    if user.id.nil?
      raise "could not update user"
    end
    log_in_as "tim@test.com", "Nope1234"
  end

  def visit_team_page
    go_to_project "Project A"
    within ".side-nav" do
      click_on "Team"
    end
  end

  def remove_user_from_project name
    within ".grid-container" do
      within ".team-member", text: name do
        find("a", text: "Remove").click()
      end
    end
    within_modal do
      click_on "Remove"
    end
    sleep(2)
  end

  def see_error_message msg
    within ".error" do
      page.should have_content(msg)
    end
  end


  def see_team_members_and_permissions
    see_user_count 4
    grab_header_rows
    see_user_expiration_and_permissions(user: "Tim Dood", expiration: "", expired: false,  
      permissions: {
        "Admin" => true,
        "Form Creation" => true,
        #"Audit Log" => true,
        "Download Data" => true,
        "View Identifying Information" => true
      })
    see_user_expiration_and_permissions(user: "Ed Mister", expiration: "1/4/2020", expired: false,  
      permissions: {
        "Admin" => false,
        "Form Creation" => true,
       #"Audit Log" => false,
        "Download Data" => false,
        "View Identifying Information" => false
      })
    see_user_expiration_and_permissions(user: "Jon Schmidt", expiration: "1/1/2012", expired: true,  
      permissions: {
        "Admin" => false,
        "Form Creation" => false,
        #"Audit Log" => true,
        "Download Data" => true,
        "View Identifying Information" => false
      })
  end

  def see_user_count(count)
    all(".team-member").count.should == count
  end

  def see_user_expiration_and_permissions(user_info)
    active_class = user_info[:expired] ? "expired" : "active"
    within ".team-member.#{active_class}", text: user_info[:user] do
      find("a", text: "View and Edit").click()
    end
    wait_for_modal_dialog
    within_modal do
      find(".date-entry").value.should == user_info[:expiration]
      user_info[:permissions].each do |permission, value|
        within ".project-wide-permissions-box label", text: permission do
          find(".yes-radio input").checked?.should == value
        end
      end
      click_on "Cancel"
    end
    wait_for_modal_close
  end

  def grab_header_rows
    within ".grid thead" do
      @headers = all("th").each_with_index.reduce({}) do |hash, (header, i)|
        hash[header.text] = i + 1
        hash
      end
    end
  end

  def column_for(permission)
    @headers[permission]
  end
end
