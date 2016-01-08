describe "project query data" do
	describe "basic functionality" do
		it "displays all reponses after querying with no parameters" do
			log_in_as_test_user
      create_project_with_form
      enter_responses("FormA", "Enter Name", "Enter date of birth")
      go_to_project_query_builder
      view_query_results
      check_query_percent("100.00")
      check_table_dimensions(4, 2)
		end
	end

	describe "query with one parameter" do
		it "displays half the reponses after querying with one parameter" do
			log_in_as_test_user
      create_project_with_two_forms
      enter_numeric_responses
      go_to_project_query_builder
      enter_query_param(1, "FormA", "var1", "<", ["3"])
      view_query_results
      check_table_dimensions(6, 1)
      check_query_percent("50.00")
		end
	end

  describe "reduce the result set forms" do
    it "shows the user selected form in result set" do
      log_in_as_test_user
      create_project_with_two_forms
      enter_numeric_responses
      go_to_project_view
      check_table_dimensions(6, 2)
      go_to_project_query_builder
      uncheck_form 1
      view_query_results
      check_table_dimensions(4, 2)
    end
  end

  describe "query from forms not in result set" do
    it "filters the results from a query from a form not selected" do
      log_in_as_test_user
      create_project_with_two_forms
      enter_numeric_responses
      go_to_project_view
      check_table_dimensions(6, 2)
      go_to_project_query_builder
      uncheck_form 0
      enter_query_param(1, "FormA", "var1", "<", ["3"])
      view_query_results
      check_table_dimensions(4, 1)
      check_query_percent("50.00")
    end
  end

  describe "2 queries with confilcting logic" do
    it "shows zero resulting subjects" do
      log_in_as_test_user
      create_project_with_two_forms
      enter_numeric_responses
      go_to_project_view
      check_table_dimensions(6, 2)
      go_to_project_query_builder
      enter_query_param(1, "FormA", "var1", ">", ["3"])
      enter_query_param(2, "FormA", "var1", "<", ["3"])
      view_query_results
      check_table_dimensions(6, 1)
      check_query_percent("0.00")
    end
  end

	def go_to_project_view()
    click_link("Data")
    sleep(2)
  end

  def go_to_project_query_builder()
    if page.all("a", :text => "Query").length == 0
      go_to_project_view()
    end
    *a, b = current_url.split("view", -1)
    str = a.join("view") + "query" + b
    visit(str)
    visit(str)
    sleep(2)
  end

  def view_query_results
    find("button", :text => "View Query Results").click
    sleep(2)
  end

  def go_to_response_entry(subject_id)
    trigger_transition do
      click_on "Form View"
      fill_in "subjectID", with: "#{subject_id}\n"
    end
  end

  def create_project_with_form(project_name="ProjectA")
    create_new_form("FormA", project_name)
    create_form_question("Date", "var2", "Enter date of birth")
    create_form_question("Text", "var1", "Enter Name")
  end

  def create_project_with_two_forms
    create_new_form("FormA", "ProjectA")
    create_form_question("Number", "var1", "num1")
    create_form_question("Number", "var2", "num2")

   go_to_ProjectA

    create_new_form_within_project("FormB")
    create_form_question("Number", "var3", "num3")
    create_form_question("Number", "var4", "num4")
  end

  def go_to_ProjectA
    visit("/#")
    visit("/#")
    trigger_transition do
      page.find("h3", :text => "ProjectA").click()
    end
  end

  def enter_responses(form_name, ques1, ques2)
    go_to_form_view("ProjectA", form_name)
    go_to_response_entry "Patient_1"
    enter_form_data 1, ques1, "Bob"
    enter_form_data 2, ques2, "8/29/1989"
    submit_form_successfully

    go_to_response_entry "Patient_2"
    enter_form_data 1, ques1, "Alice"
    enter_form_data 2, ques2, "08/19/1989"
    submit_form_successfully
    go_to_form_view("ProjectA", form_name)
  end

  def enter_numeric_responses
  	go_to_form_view("ProjectA", "FormA")
    go_to_response_entry "Patient_1"
    enter_form_data 2, "num1", "1"
    enter_form_data 1, "num2", "2"
    submit_form_successfully

    go_to_response_entry "Patient_2"
    enter_form_data 2, "num1", "3"
    enter_form_data 1, "num2", "4"
    submit_form_successfully

    go_to_form_view("ProjectA", "FormB")
    go_to_response_entry "Patient_1"
    enter_form_data 2, "num3", "4"
    enter_form_data 1, "num4", "3"
    submit_form_successfully

    go_to_response_entry "Patient_2"
    enter_form_data 2, "num3", "2"
    enter_form_data 1, "num4", "1"
    submit_form_successfully
    go_to_form_view("ProjectA", "FormA")
  end

  def enter_query_param(number, form_name, question_name, operator, value)
    sleep(1)
    click_button "Add Query Parameter"
    enter_dropdown_from_id("form-#{number}", form_name)
    sleep(1)
    enter_dropdown_from_id("question-#{number}", question_name)
    sleep(1)
    enter_dropdown_from_id("operator-#{number}", operator)
    within("#value-#{number}") do
      if all(".drop-down-input").length == 1
        enter_dropdown_from_id("value-#{number}", value)
      else
        value.each_with_index do |val, i|
          all("input")[i].set(val)
        end
      end

    end
  end

  #def set_dropdown_val(node, val)
  #  page.execute_script %Q{
  #    $(".drop-down-test").removeClass("hide");
  #  }
  #  within(node.find(".drop-down-test")) do
  #    find("input").set(val)
  #    find("button").click
  #  end
  #end

  def uncheck_form (form_index)
    page.all(".singleFormSelect")[form_index].set(false)
  end

  def check_table_dimensions(width, height)
    page.assert_selector("#main-data-table th", :count => width)
    page.assert_selector("#main-data-table tbody tr", :count => height)
  end

  def check_query_percent(percent)
  	page.find(".result-header").should have_content("#{percent}%")
  end
end