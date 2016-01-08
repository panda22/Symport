module UserHelpers
  def log_in_as_test_user
    user = create :user, email: "test@test.com", password: "Nope1234", demo_progress: 6, super_user: true, phone_number: "1234567890"
    if user.id.nil?
      raise "could not create user"
    end
    if Project.first
      TeamMember.create! project_id: Project.first.id, user_id: user.id, administrator: true, view_personally_identifiable_answers: true, form_creation: true, audit: true, export: true   
    end
    log_in_as "test@test.com", "Nope1234"
  end

  def log_in_as(user_email, password)
    visit "/#"
    if page.has_link?("Sign Out")
      trigger_transition do
        find_link("Sign Out").trigger("click")
      end
    end
    sleep 1
    within ".sign-in" do
      fill_in "E-mail", with: user_email
      fill_in "Password", with: password
      trigger_transition do
        find_button("Log In").trigger("click")
      end
    end
  end
end
