describe "view and query question types view" do
	describe "text type" do
		it "displays a text question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Text", "var1", "Enter text")
    	enter_responses("Enter text", "hello", "hi")
    	go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "=", ["hi"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end

	describe "date type" do
		it "displays a date question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Date Field", "var1", "Enter date")
    	enter_responses("Enter date", "11/11/2011", "11/12/2011")
    	go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "<", ["11/12/2011"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end
	

	describe "zipcode type" do
		it "displays a zipcode question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Zipcode", "var1", "Enter date")
    	enter_responses("Enter date", "11111", "22222")
    	go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "≠", ["11111"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end
	
	describe "email type" do
		it "displays a email question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Email", "var1", "Enter email")
    	enter_responses("Enter email", "1@1.com", "2@2.com")
    	go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "=", ["2@2.com"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end

	describe "Number type" do
		it "displays a Number question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
    	create_form_question("Number", "var1", "Enter number")
    	enter_responses("Enter number", "12", "2")
    	go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "≤", ["12"])
    	view_query_results
    	check_table_dimensions(3, 2)
    	check_query_percent(100)
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
			go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "contains", ["one"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end

	describe "radio buttons type" do
		it "displays a radio buttons question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Multiple Choice / Radio Buttons", "var1", "Choose" do
				enter_answer_option "one"
				enter_answer_option "two"
			end
			enter_responses("Choose", "one", "two")
			go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "=", ["one"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
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
			go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "≠", ["three"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end

	describe "yes/no type" do
		it "displays a yes/no question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Yes/No", "var1", "Choose"
			enter_responses("Choose", "Yes", "No")
			go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "=", ["Yes"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end

	describe "timestamp type" do
		it "displays a timestamp question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Time of day", "var1", "Choose"
			enter_responses("Choose", ["1", "11", "AM"], ["2", "22", "AM"])
			go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "≥", ["1", "51"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end

	describe "time duration type" do
		it "displays a time duration question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Time duration", "var1", "Choose"
			enter_responses("Choose", ["1", "1", "1"], ["2", "2", "2"])
			go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "=", ["02", "02", "02"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end

	describe "phone number type" do
		it "displays a phone number question" do
			log_in_as_test_user
			create_new_form("FormA", "ProjectA")
			create_form_question "Phone number", "var1", "Choose"
			enter_responses("Choose", ["111", "111", "1111"], ["222", "222", "2222"])
			go_to_project_query_builder
    	enter_query_param(1, "FormA", "var1", "=", ["111", "111", "1111"])
    	view_query_results
    	check_table_dimensions(3, 1)
    	check_query_percent(50)
		end
	end


	def enter_responses(question, answer1, answer2)
		go_to_form_view("ProjectA", "FormA")
    go_to_response_entry "Patient_1"
    enter_form_data 1, question, answer1
    submit_form_successfully

    go_to_form_view("ProjectA", "FormA")
    go_to_response_entry "Patient_2"
    enter_form_data 1, question, answer2
    submit_form_successfully
	end

	def go_to_project_view(project_name="ProjectA")
    trigger_transition do
      go_to_project(project_name)
    end
    trigger_transition do
      page.find(".view-data-icon").click()
    end
  end

  def sort_grid_and_check(answer1, answer2, var="var1")
  	page.find("#sortVariableChooser").set(var)
  	page.find("#sortTypeChooser").set("Ascending empty on bottom")
  	page.all("tr.default td")[2].text.should == answer1
  	page.find("#sortVariableChooser").set(var)
  	page.find("#sortTypeChooser").set("Descending empty on bottom")
  	page.all("tr.default td")[2].text.should == answer2
  end

  def go_to_response_entry(subject_id)
    trigger_transition do
      click_on "Form View"
      fill_in "subjectID", with: "#{subject_id}\n"
    end
  end

  def enter_query_param(number, form_name, question_name, operand, value)
    click_button "Add Query Parameter"
    within page.find("#query-" + number.to_s) do
      if form_name != ""
        all("input")[0].set(form_name)
      end
      if question_name != ""
        all("input")[1].set(question_name)
      end
      if operand != ""
        op_select = page.all("select")[0]
        op_select.click()
        within(op_select) do
          select(operand)
        end
      end
      if value != ""
        all("input")[2].click()
        (2..value.length + 1).each do |index|
          all("input")[index].set(value[index - 2])
        end
      end
    end
  end

  def check_table_dimensions(width, height)
    page.assert_selector("th.default", :count => width)
    page.assert_selector("tr.default", :count => height)
  end

  def check_query_percent(percent)
  	page.assert_selector(".row.query-results h1", :text => "#{percent}%")
  end

  def go_to_project_query_builder(project_name="ProjectA")
    go_to_project_view(project_name)
    trigger_transition do
    	page.find("a", :text => "Query").click()
    end
    sleep 2
  end

  def view_query_results
    trigger_transition do
      click_button "Run Query"
    end
  end
end