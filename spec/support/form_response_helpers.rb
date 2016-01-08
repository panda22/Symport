module FormResponseHelpers

  def edit_response_for(project_name, form_name, subject_id)
    go_to_form_view project_name, form_name

    fill_in "subjectID", with: "#{subject_id}\n"

    page.should have_content "VIEWING SUBJECT ID → #{subject_id}"
  end

  def rename_subject_id(new_subject_id)
    find("a", text: "Rename ID").click()
    #click_link "Rename ID"
    wait_for_modal_dialog
    within_modal do
      find(".subject-id-rename").set new_subject_id
      click_button "Save"
    end
  end

  def delete_current_response(confirm: true)
    find("a", text: "Delete").click()
    #click_link "Delete"
    wait_for_modal_dialog
    if confirm
      click_button "Delete"
    else
      click_button "Cancel"
    end
  end

  def see_not_editing_response
    page.should_not have_content "VIEWING SUBJECT ID"
    page.should have_content "Enter data into"
  end

  def see_editing_response_for_subject_id(subject_id)
    page.should have_content "VIEWING SUBJECT ID → #{subject_id}"
  end

  def enter_form_data(sequence_number, prompt, answer=nil)
    within ".form-answer", text: prompt do
      page.should have_content sequence_number
      page.should have_content prompt
      unless answer.nil?
        if answer.is_a? Array
          all("input,select").zip(answer) do |(elem, v)|
            if elem.tag_name == "input"
              elem.set(v)
            else
              elem.find(:option, v).select_option
            end
          end
        else
          if current_scope.has_selector?(".drop-down-input")
            enter_dropdown_input(current_scope, sequence_number, answer)
          elsif current_scope.has_selector?("input[type='text']")
            find('input').set(answer)
          elsif current_scope.has_selector?("textarea")
            find("textarea").set(answer)
          elsif current_scope.has_selector?("input[type='checkbox']")
            all("input").each do |input|
              input.set(false)
            end
            check(answer)
          elsif current_scope.has_selector?("input[type='radio']")
            choose(answer)
          elsif current_scope.has_selector?("select")
            within('select') do
              select(answer)
            end
          else
            find("input").set answer
          end
        end
      end

      yield if block_given?
    end
  end

  # enter into drop down questions only
  def enter_dropdown_input(scope, container_id, input)
    script = "$('##{container_id}').closest('.form-answer-box').find('.drop-down-test').toggleClass('hide')"
    page.driver.browser.execute_script(script)
    within scope.find(".drop-down-test") do
      find("input").set(input)
      find("button").click
    end
    page.driver.browser.execute_script(script)
    scope.click
  end


  # enter into any drop down
  # id: id tag of element containing dropdown
  # must exclude # sign
  # can have additional selectors after
  # example: #my-id .my-class would be sent as "my-id .my-class"
  def enter_dropdown_from_id(id, input)
    script = "$('##{id}').find('.drop-down-test').toggleClass('hide')"
    page.driver.browser.execute_script(script)
    within find("##{id} .drop-down-test") do
      find("input").trigger("focus")
      find("input").set(input)
      find("button").click
    end
    page.driver.browser.execute_script(script)
    find("##{id}").click
  end

  def see_response_is_not_new
    page.should_not have_content "This is a new Subject ID in this project"
  end

  def submit_form
    click_button "Save"
    sleep 3
  end

  def question_should_be_grayed_out(sequence_number, prompt)
    within ".form-answer", text: prompt do
      page.should have_selector(".conditionally-disabled")
    end
  end

  def question_should_not_be_grayed_out(sequence_number, prompt)
    within ".form-answer", text: prompt do
      page.should_not have_selector(".conditionally-disabled")
    end
  end

  def view_form_data_grayed_out(sequence_number, prompt)
    within ".form-answer", text: prompt do
      find(".question-number").click
      page.should (have_selector(".description", visible: false) || have_selector(".description", visible: true))
    end
  end

  def submit_form_successfully
    submit_form
    page.should have_selector ".form-response .success"
  end

  #gray is 0, green is 1, red is 2, blue is 3
  def check_answer_coloring (prompt, color)
    within ".form-answer", text: prompt do
      page.should have_content prompt
      if color == 0
        page.should_not have_selector ".filled-in-heading.no-error-heading"
        page.should_not have_selector ".filled-in-heading.error-heading"
        page.should_not have_selector ".empty-saved-heading.no-error-heading"
      elsif color == 1
        page.should have_selector ".filled-in-heading.no-error-heading"
      elsif color == 2
        page.should have_selector ".filled-in-heading.error-heading"
      elsif color == 3
        page.should have_selector ".empty-saved-heading.no-error-heading"
      end
    end
  end

  def view_form_data(sequence_number, prompt, answer)
    #if current_url =~ /(.+)\/edit$/ # FIXME HACK to deal with how we don't view R/O anymore
    #  visit "#{$1}/view"
    #end
    within ".form-answer", text: prompt do
      page.should have_content "#{sequence_number}"
      page.should have_content prompt
      #current_scope.should have_text answer
      if current_scope.has_selector?("input")
        find('input').value.should == (answer)
      elsif current_scope.has_selector?("textarea")
        find("textarea").value.should == (answer)
      #elsif current_scope.has_selector?("input[type='checkbox']")
      #  FUUUUUCKKKK
      else
        find('select').value.should == (answer)
      end
    end
  end

  def view_conditional_logic_label(question_number, prompt, label)
    within ".form-answer", text: prompt do
      # page.should have_content "#{question_number}."
      page.should have_content label
    end
  end


  def see_editable_question_has_response(question_text, answer_text, options = {})
    options = {element: "input"}.merge options
    page.within ".form-answer", text: question_text do
      find(options[:element]).value.should eq answer_text
    end
  end

  def see_response_values(number, values)
    rows = all "tbody tr"
    row = rows[number - 1]
    values.each do |value|
      row.should have_text value
    end
  end

  def see_response_no_values(number, values)
    rows = all "tbody tr"
    row = rows[number - 1]
    values.each do |value|
      row.should_not have_text value
    end
  end

end
