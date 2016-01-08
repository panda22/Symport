describe "phi permissions spec" do
  before do
    create_a_project_and_team
    create_forms
    log_in_as_ed
  end

  it "verifies that other users cannot see, edit phi stuffs on form grid, entry form and view form and also cannot make phi questions not phi" do
    go_to_form_responses("Project A", "Cool Form")
    go_to_response_entry("subject_id")

    see_question_is_filtered_phi "baz"
    see_question_is_filtered_phi "foo"

    enter_form_data 2, "bar", "a response"
    submit_form_successfully

    see_question_is_filtered_phi "baz"
    see_question_is_filtered_phi "foo"
    view_form_data("2", "bar", "a response")
  end

  it "allows user to set personally identifiable flag" do
    go_to_project("Project A")
    within(".form-structure-container") do
      click_on "Build Form"
    end
    edit_question 2, "bar" do
      within '.question-builder-field', text: 'Identifying Information:' do
        choose "Yes"
      end
      true
    end
    go_to_form_responses("Project A", "Cool Form")
    go_to_response_entry("subject_id2")
    see_question_is_filtered_phi "bar"

    go_to_project("Project A")
    within(".form-structure-container") do
      click_on "Build Form"
    end
    edit_question 2, "bar" do
      within '.question-builder-field', text: 'Identifying Information:' do
        choose "No"
      end
      true
    end

    page.should have_content('You cannot unset the personally identifiable flag for this question')
    click_button "Cancel"

    go_to_form_responses "Project A", "Cool Form"
    go_to_response_entry "subject_id"
    see_question_is_filtered_phi "bar"
  end


  def create_forms
    project = Project.first
    form = FormStructure.create!(name: 'Cool Form')
    ed = User.find_by email: "ed@test.com"
    ed_member = ed.team_members.first
    FormStructurePermission.create! form_structure: form, team_member: ed_member, permission_level: "Full"

    text_config1 = TextConfig.create! size: "normal"
    text_config2 = TextConfig.create! size: "normal"
    text_config3 = TextConfig.create! size: "normal"
    question_1 = FormQuestion.create! variable_name: 'var1', sequence_number: 1, display_number: "1", question_type: 'text', prompt: "baz", text_config: text_config1, personally_identifiable: true
    question_2 = FormQuestion.create! variable_name: 'var2', sequence_number: 2, display_number: "2", question_type: 'text', prompt: "bar", text_config: text_config2
    question_3 = FormQuestion.create! variable_name: 'var3', sequence_number: 3, display_number: "3", question_type: 'text', prompt: "foo", text_config: text_config3, personally_identifiable: true

    form.form_questions << [question_1, question_2, question_3]
    project.form_structures << form
  end

  def log_in_as_ed
    ed = User.find_by email: "ed@test.com"
    ed.update_attributes!(password: "Complex1")
    log_in_as(ed.email, "Complex1")
  end

  def see_question_is_filtered_phi(prompt)
    within '.form-answer-box', text:prompt do
      page.should have_content "The answer is identifying information and not displayed due to your permissions."
      page.should_not have_selector "input"
    end
  end

  def go_to_response_entry(subject_id)
    trigger_transition do
      click_on "Form View"
      fill_in "subjectID", with: "#{subject_id}\n"
    end
  end
end
