describe "creating and updating user accounts" do
  it "allows new user sign up" do
    create_a_new_user
    log_in_as_new_user
    see_new_user_profile
  end

  it "allows editing of user profile" do
    create_a_pre_existing_user
    log_in_as_pre_existing_user
    update_pre_existing_user_profile
    see_pre_existing_profile_changes
  end

  it "checks if my EULA stuff worked" do
    create_a_new_user
  end

  def create_a_new_user
    visit "/#"
    click_on "Create an Account"
    within "div.sign-up" do
      find(".firstName").set("New")
      find(".lastName").set("User")
      #fill_in "Affiliation", with: "Owls"
      #fill_in "Field of study", with: "CS"
      find(".email").set("owl@rice.edu")
      find(".test-pwd-selector").set("blue_and_grayA1")
      find(".passwordConfirmation").set("blue_and_grayA1")
      find(".phone").set("1234567890")
      page.check('eulaCheckbox')
      sleep 1
      click_on "Create an Account"
      sleep 2
    end
  end

  def log_in_as_new_user
    log_in_as "owl@rice.edu", "blue_and_grayA1"
  end

  def see_new_user_profile
    find_link("Update Profile").trigger("click")
    find(".first-name-selector").value.should == "New"
    find(".last-name-selector").value.should == "User"
    #find(:fillable_field, "Affiliation").value.should == "Owls"
    #find(:fillable_field, "Field of study").value.should == "CS"
    page.should have_content "owl@rice.edu"
  end

  def create_a_pre_existing_user
    create :user, email: "existing@user.com", password: "Testy123",
      first_name: "Some", last_name: "Guy", affiliation: "Packers", field_of_study: "football"
  end

  def log_in_as_pre_existing_user
    log_in_as "existing@user.com", "Testy123"
  end

  def update_pre_existing_user_profile
    click_on "Update Profile"
    find(".first-name-selector").set("New")
    find(".affil-selector").set("Lions")
    find(".pwd-selector").set("Testy123")
    click_button "save-update-profile"
  end

  def see_pre_existing_profile_changes
    click_on "Update Profile"
    find(".first-name-selector").value.should == "New"
    find(".last-name-selector").value.should == "Guy"
    find(".affil-selector").set("Lions")
    find(".field-selector").set("football")
  end
end
