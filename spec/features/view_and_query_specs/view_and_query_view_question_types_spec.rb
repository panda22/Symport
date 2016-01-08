describe "view and query question types query" do
	describe "text type" do
		it "displays a text question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Text", "var1", "Enter text")
    	enter_responses("Enter text", "hello", "hi")
    	go_to_project_view
    	sort_grid_and_check("hello", "hi")
		end
	end

	describe "date type" do
		it "displays a date question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Date Field", "var1", "Enter date")
    	enter_responses("Enter date", "11/11/2011", "11/12/2011")
    	go_to_project_view
    	page.find("#main-data-table").should have_content("11/11/2011")
		end
	end
	
	describe "zipcode type" do
		it "displays a zipcode question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Zipcode", "var1", "Enter date")
    	enter_responses("Enter date", "11111", "22222")
    	go_to_project_view
    	sort_grid_and_check("11111", "22222")
		end
	end
	
	describe "email type" do
		it "displays a email question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Email", "var1", "Enter email")
    	enter_responses("Enter email", "1@1.com", "2@2.com")
    	go_to_project_view
    	sort_grid_and_check("1@1.com", "2@2.com")
		end
	end

	describe "Number type" do
		it "displays a Number question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Number", "var1", "Enter number")
    	enter_responses("Enter number", "12", "2")
    	go_to_project_view
    	page.find("#main-data-table").should have_content("12")
		end
	end

	describe "checkboxes type" do
		it "displays a checkboxes question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Checkbox", "var1", "Choose" do
				enter_answer_option "one"
				enter_answer_option "two"
			end
			enter_responses("Choose", "one", "two")
			go_to_project_view
			sort_grid_and_check("one", "two")
		end
	end

	describe "radio buttons type" do
		it "displays a radio buttons question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Multiple Choice", "var1", "Choose" do
				enter_answer_option "one"
				enter_answer_option "two"
			end
			enter_responses("Choose", "one", "two")
			go_to_project_view
			sort_grid_and_check("one", "two")
		end
	end

	describe "dropdown type" do
		it "displays a dropdown question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Dropdown", "var1", "Choose" do
				enter_answer_option "two"
				enter_answer_option "three"
			end
			enter_responses("Choose", "two", "three")
			go_to_project_view
			sort_grid_and_check("three", "two")
		end
	end

	describe "yes/no type" do
		it "displays a yes/no question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Yes/No", "var1", "Choose"
			enter_responses("Choose", "Yes", "No")
			go_to_project_view
			sort_grid_and_check("No", "Yes")
		end
	end

	describe "timestamp type" do
		it "displays a timestamp question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Time of day", "var1", "Choose"
			enter_responses("Choose", ["1", "11", "AM"], ["2", "22", "AM"])
			go_to_project_view
			page.find("#main-data-table").should have_content("1:11 AM")
		end
	end

	describe "time duration type" do
		it "displays a time duration question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Time duration", "var1", "Choose"
			enter_responses("Choose", ["1", "11", "11"], ["2", "22", "22"])
			go_to_project_view
			page.find("#main-data-table").should have_content("1:11:11")
		end
	end

	describe "phone number type" do
		it "displays a phone number question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Phone number", "var1", "Choose"
			enter_responses("Choose", ["111", "111", "1111"], ["222", "222", "2222"])
			go_to_project_view
			sort_grid_and_check("(111)-111-1111", "(222)-222-2222")
		end
	end

	def transition_to_form_view(project="ProjectA", form_name="FormA")
    trigger_transition do
      click_link "Project Home"
    end
    trigger_transition do
      within(page.find(".form-structure-container", :text => form_name)) do
        click_button("Enter/Edit Data")
      end
    end
  end

	def enter_responses(question, answer1, answer2)
		transition_to_form_view("ProjectA", "FormA")
    go_to_response_entry "Patient_1"
    enter_form_data 1, question, answer1
    submit_form_successfully

    transition_to_form_view("ProjectA", "FormA")
    go_to_response_entry "Patient_2"
    enter_form_data 1, question, answer2
    submit_form_successfully
	end

	def go_to_project_view(project_name="ProjectA")
    if page.all(".view-data-icon").length == 0
      go_to_project(project_name)
    end
    trigger_transition do
      page.find(".view-data-icon").click()
    end
  end

  def sort_grid_and_check(answer1, answer2, var_num=0)
  	set_dropdown_val(page.find(".sort-variable-drop-down"), "var1")
  	set_dropdown_val(page.find(".sort-type-drop-down"), "A-Z 0-9 unfilled last")
  	sleep(1)
  	page.all("#main-data-table tbody tr")[0].should have_content(answer1)
  	sleep(1)
  	set_dropdown_val(page.find(".sort-type-drop-down"), "Z-A 9-0 unfilled last")
  	page.all("#main-data-table tbody tr")[0].should have_content(answer2)
  end

  def go_to_response_entry(subject_id)
    trigger_transition do
      click_on "Form View"
      fill_in "subjectID", with: "#{subject_id}\n"
    end
  end

  def set_dropdown_val(node, val)
  	page.execute_script %Q{
  		$(".drop-down-test").removeClass("hide");
  	}
  	within(node.find(".drop-down-test")) do
  		find("input").set(val)
  		find("button").click
  	end
  end
end