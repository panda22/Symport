module QuestionEditorHelpers
  def create_new_form(name="Temp", project_name="Project")
    visit "/#"
    create_a_project(project_name)
    create_new_form_within_project(name)
  end

  def create_new_form_within_project(name="Temp")
    open_modal "Create a New Form"
    within ".dialog" do
      find(".form-name").set name
      click_button "Create"
    end
    wait_for_modal_close
  end

  def create_dependent_form_question(type, variable_name, prompt, opts={})
    start_form_last_question type, variable_name, prompt, opts do
      yield if block_given?
    end

    opts[:parents].each_with_index do |parent_info, parent_index|
      click_button "Add If Statement"
      sleep 1
      enter_parent_question_info parent_index + 1, parent_info
    end

    click_button "Save and Add Question"
    wait_for_modal_close
  end

  def enter_parent_question_info condition_number, parent_info
    within all(".conditions")[condition_number-1] do
      select_question parent_info[:question]
      select_logic parent_info[:logic]
      select_value parent_info[:value]
    end
  end

  def select_question question
    within(".select-condition-question") do
      select(question)
    end
  end

  def select_logic logic
    within(".logic-selector") do
      select(logic)
    end
  end

  def select_value value
    within(".condition-value") do
      if value.is_a? Array
        all("input,select").zip(value) do |(elem, v)|
          if elem.tag_name == "input"
            elem.set(v)
          else
            elem.find(:option, v).select_option
          end
        end
      else
        if current_scope.has_selector?("input")
          find('input').set(value)
        else
          within("select") do
            select(value)
          end
        end
      end
    end
  end

  def start_form_question(type, variable_name, prompt, opts={})
    open_new_question_modal "Add Question or Formatting"
    fill_basic_question_info type, variable_name, prompt, opts do
      yield if block_given?
    end
  end

  def start_form_last_question(type, variable_name, prompt, opts={})
    open_new_last_question_modal "Add Question or Formatting"
    fill_basic_question_info type, variable_name, prompt, opts do
      yield if block_given?
    end
  end

  def fill_basic_question_info(type, variable_name, prompt, opts = {})
    select_type type
    enter_variable_name variable_name if variable_name.present?
    enter_prompt prompt if prompt.present?
    opts.each do |k,v|
      if k != :parents
        if k == "Description"
          enter_description v
        elsif k == "Exceptions"
          enter_exceptions v
        else
          enter_typed_option k, v
        end
      end
    end
    yield if block_given?
  end

  def create_form_question(type, variable_name, prompt, opts={})
    start_form_question type, variable_name, prompt, opts do
      yield if block_given?
    end
    click_button "Save and Add Question"
    wait_for_modal_close
  end

  def preview_form_question(type, variable_name, prompt, opts={})
    start_form_question type, variable_name, prompt, opts do
      yield if block_given?
    end
    view_question_preview
  end

  def select_type(type)
    within ".question-type" do
      select type
    end
  end

  def enter_prompt(prompt_text)
    find(".question-prompt").set(prompt_text)
    find(".question-prompt").value.should == prompt_text
  end

  def enter_variable_name(variable_name)
    find(".question-variable-name").set(variable_name)
    find(".question-variable-name").value.should == variable_name
  end

  def enter_typed_option(option_name, option_value)
    within ".question-builder-field-type-specific", text: option_name do
      if option_name == "Size"
        within ".option-value" do
          select option_value
        end
      else
        within ".columns", text: option_name do
          elem = find(".option-value")
          if elem.tag_name == "select"
            within ".option-value" do
              select option_value
            end
          else
            elem.set option_value
          end
        end
      end
    end
  end

  def enter_description(prompt_text)
    find(".question-description").set(prompt_text)
    find(".question-description").value.should == prompt_text
  end

  def view_question_preview
    #page.check "Preview"
  end

  def complete_form_and_enter_data(form_name="Temp", new_subject=true, subject_id="abc123")
    complete_form_and_select_subject(form_name, new_subject, subject_id)
  end

  def complete_form_and_fail_to_enter_data(form_name="Temp", new_subject=true, subject_id="abc123")
    complete_form_and_select_subject(form_name, new_subject, subject_id)
    page.should have_selector ".response-lookup-error"
  end

  def question_preview_has_content(prompt, description=nil, &block)
    within ".form-answer", text: prompt do
      if description
        page.should have_content description
      end
      yield block if block_given?
    end
  end

  def wait_for_modal_dialog
    page.should have_selector ".dialog.open"
  end

  def wait_for_modal_close
    #page.should_not have_selector ".dialog"
    sleep 2
    page.should_not have_selector(".dialog")
    sleep 2
    # even after .dialog-bg happens, the modal content Views may still be in memory
    # i.e. willRemoveElement has not been called yet, and summoning the view again will not call didInsertElement
    # we made a change to modal handling to try and ensure that re-triggers only happen after delete/re-create of Views, but it 
    # doesn't always work
  end

  def open_modal(button_text)
    click_link_or_button button_text
    wait_for_modal_dialog
  end

  def open_new_question_modal(button_text)
    within ".add-question-button-row:first-of-type" do
      click_link_or_button button_text
    end
    wait_for_modal_dialog 
  end

  def open_new_last_question_modal(button_text)
    within ".form-question-container:last-of-type" do
      click_link_or_button button_text
    end
    wait_for_modal_dialog 
  end

  def within_modal
    within ".dialog" do
      yield
    end
  end

  def enter_answer_option(text)
    if page.has_no_selector?(".sample-answer")
      click_button "Add Answer Choice"
    end
    within ".div-for-test" do
      within ".typed-ui .answer-choice-row:last-of-type" do
        find(".option-value").set(text)
      end
    end
  end

  def edit_question(number, prompt)
    within ".form-question-container", text: prompt do
      find('a', text: 'Edit').click
    end
    wait_for_modal_dialog
    save = block_given? ? yield : false
    if save
      button = "Save and Add Question"
      if has_button?('Save Question')
        button = "Save Question"
      end
      click_on button
    else
      click_button "Cancel"
    end
  end

  def create_branched_question_out_of(number, prompt)
    within ".form-question-container", text: prompt do
      find('a', text: 'Create Branched Question').click
    end
    wait_for_modal_dialog
    save = block_given? ? yield : false
    if save
      click_button "Save and Add Question"
    else
      click_button "Cancel"
    end
  end

  def duplicate_question(number, prompt)
    within ".form-question-container", text: prompt do
      find('a', text: 'Duplicate').click
    end
    wait_for_modal_dialog
    save = block_given? ? yield : false
    if save
      click_button "Save and Add Question"
    else
      click_button "Cancel"
    end
  end

  def see_that_type_can_be_changed(type)
    page.should have_selector "select.question-type"
  end

  def see_that_type_cannot_be_changed(type)
    page.should have_selector "select.question-type:disabled"
  end

  private
    def complete_form_and_select_subject(form_name="Temp", new_subject=true, subject_id="abc123")
      sleep 1
      form = FormStructure.where(name: form_name).first
      project = form.project
      visit "/#/projects/#{project.id}/forms/#{form.id}/responses"
      visit "/#/projects/#{project.id}/forms/#{form.id}/responses"
      fill_in "subjectID", with: "#{subject_id}\n"
    end
end
