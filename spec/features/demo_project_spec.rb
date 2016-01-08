describe "testing the demo project" do
  describe "create a new user" do
    before do
      visit "/#"
      click_on "Create an Account"
      within "div.sign-up" do
        find(".firstName").set("New")
        find(".lastName").set("User")
        find(".email").set("owl@rice.edu")
        find(".test-pwd-selector").set("blue_and_grayA1")
        find(".passwordConfirmation").set("blue_and_grayA1")
        click_on "Create an Account"
      end
    end

    it "checks that initial onboarding works properly" do
      page.should have_selector ".joyride-tip-guide"
      page.find(".joyride-tip-guide", text: "Welcome to Symport.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click

      page.find(".joyride-tip-guide", text: "Click on the Demo Project to get started!").should be_visible
      page.find(".joyride-next-tip", text: "Get Started").click
 
      go_to_project("Demo Project")

      page.find(".joyride-tip-guide", text: "These are your forms.").should be_visible
      page.find("#demoEnterEdit").click

      page.find(".joyride-tip-guide", text: "To add to a new record or to view an existing one, type the subject ID into the Subject ID box and hit enter.").should be_visible
      fill_in 'subjectID', :with => "100\n"

      log_in_as("owl@rice.edu", "blue_and_grayA1")

      go_to_project("Demo Project")
      page.find(".button.pencil-with-text").click
      fill_in 'subjectID', :with => "100\n"

      page.find(".joyride-tip-guide", text: "To add data to a record, type in the information or select the correct answer option.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click

      enter_form_data 3, "Were you satisfied with your care?", "Yes"

      page.find(".joyride-tip-guide", text: "When finished editing a record, make sure to save the changes before leaving the page.").should be_visible
      submit_form
      page.find("#savingButton button").click

      page.find(".dataText")[:class].include?("animated")

      go_to_project("Demo Project")

      page.find(".view-data-icon").click

      page.find(".joyride-tip-guide", text: "This is the data page").should be_visible

      demo_progress = DemoProgress.first()
      demo_progress.view_data_sort_search = true
      demo_progress.save!
      project = Project.first()

      go_to_project("Demo Project")
      visit "#/projects/#{project.id}/view-and-query/saved-queries"
      sleep 5
      page.find(".joyride-tip-guide", text: "Click create a new query to find all of the subjects matching different parameters.").should be_visible
      page.find("button.button.plus-with-text").click

      page.find(".joyride-tip-guide", text: "To build a query, choose the forms whose data you would like to view, then build the query parameters to filter your data.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click
      page.find(".joyride-tip-guide", text: "Try building a query that searches for all of the records which indicate satisfaction with their visit.").should be_visible     
      
      #initial onboarding test case abandoned at the point where the user is building a query
      #fill_in 'buildQueryInfo2', :with => "Yes\n"
      #page.find(".button.right.submit-query").click
      #sleep 5
      #page.save_screenshot "queryresults.png"
      #puts page.all("a", :text => "Query").length
      #page.find("a", :text => "Query").click
    end

    it "additional onboarding" do
      sleep 5

      create :user, email: "steve@symport.com", password: "Complex1", first_name: "Steve", last_name: "Symport", demo_progress: 6

      page.should have_selector ".joyride-tip-guide"
      page.find(".joyride-tip-guide", text: "Welcome to Symport.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click

      page.find(".joyride-tip-guide", text: "Click on the Demo Project to get started!").should be_visible
      page.find(".joyride-next-tip", text: "Get Started").click
 
      go_to_project("Demo Project")

      demo_progress = DemoProgress.first()
      demo_progress.form_enter_edit = true
      demo_progress.enter_edit_subject_id = true
      demo_progress.enter_edit_response = true
      demo_progress.enter_edit_save = true
      demo_progress.data_tab_emphasis = true
      demo_progress.view_data_sort_search = true
      demo_progress.create_new_query = true
      demo_progress.build_query_info = true
      demo_progress.build_query_params = true
      demo_progress.query_results_download = true
      demo_progress.query_results_breadcrumbs = true
      demo_progress.import_button = true
      demo_progress.import_overlays = true
      demo_progress.import_csv_text = true
      demo_progress.save!
 
      go_to_project("Demo Project")

      page.find(".joyride-tip-guide", text: "Congratulations, you're now free to explore the remaining features at your own will.").should be_visible
      page.find(".joyride-next-tip", text: "Continue").click

      page.find(".teamText")[:class].include?("animated")
      page.find(".importText")[:class].include?("animated")

      page.find(".teamText").click

      page.find(".joyride-tip-guide", text: "Click the Add Team Member button to add a new team member.").should be_visible
      page.find("#addTeamMemberButton").click

      page.find(".joyride-tip-guide", text: "Try adding someone to your team now.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click

      page.find(".joyride-tip-guide", text: "Project Wide Permissions control a user's level of access across the entire project.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click

      page.find(".joyride-tip-guide", text: "Form specific permissions help you control access to each specific form.").should be_visible

      page.find(".button.right.main.big-dialog").click

      go_to_project("Demo Project")

      page.find(".button.hammer-with-text.left").click

      page.find(".joyride-tip-guide", text: "Use the Form Builder to add, edit, or delete questions.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click

      page.find(".joyride-tip-guide", text: "Try adding a question now.").should be_visible
      page.find("#addAQuestion").click      

      page.find(".joyride-tip-guide", text: "Every question you add must have a Prompt.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click

      page.find(".joyride-tip-guide", text: "Your variable name will display in the first row of any column containing this question's data.").should be_visible
      page.find(".joyride-next-tip", text: "Next").click      

      page.find(".joyride-tip-guide", text: "If responses to this question might contain identifying information or protected").should be_visible

      within_modal do
        click_on "Save and Add Question"
        click_on "Cancel"
        wait_for_modal_close
      end

      #sleep 10
      #page.save_screenshot "clickedteam.png"


    end



  end
end