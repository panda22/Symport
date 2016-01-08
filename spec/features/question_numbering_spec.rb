describe "question numbering" do
  before do
    log_in_as_test_user
  end

  it "shows the question numbers not sequence numbers" do
    create_form_with_formatting_questions
    see_form_builder_with_correct_sequence_numbers
    see_form_entry_with_correct_sequence_numbers
  end

  it "allows specifying a new question before second question" do
    create_a_new_question_and_reposition_it_to_before_second_question
    see_new_question_before_second_question
  end

  it "allows specifying a new question after last question" do
    create_a_new_question_and_reposition_it_to_after_fourth_question
    see_new_question_after_fourth_question
  end

  it "allows editing third question and moving it before second question" do
    edit_third_question_and_reposition_it_to_before_second_question
    see_repositioned_question_in_place_before_old_second_question
  end

  it "allows editing third question and moving it after second question" do
    edit_third_question_and_reposition_it_to_after_second_question
    see_repositioned_question_in_place_after_second_question
  end

  it "allows editing fourth question and moving it before first question" do
    edit_fourth_question_and_reposition_it_to_before_first_question
    see_repositioned_question_in_place_first_in_the_list
  end

  it "allows editing fourth question and moving it after first question" do
    edit_fourth_question_and_reposition_it_to_after_first_question
    see_repositioned_question_in_place_second_in_the_list
  end

  def edit_fourth_question_and_reposition_it_to_after_first_question
    form = create :structure_research_form_a
    go_to_project "Project A"
    edit_form "Research Form A"
    within ".form-question-container", text: "Send email to?" do
      find('a', text: 'Edit').click
    end
    wait_for_modal_dialog

    within '.question-sequencing' do
      within '#sequence-dropdown' do
        select('After 1: What is your favorite color?')
      end
    end
    click_on "Save Question"
  end

  def see_repositioned_question_in_place_second_in_the_list
    within ".form-question", text: "What is your favorite color?" do
      within ".question-number" do
        page.should have_content '1'
      end
    end

    within ".form-question", text: "Send email to?" do
      within ".question-number" do
        page.should have_content '2'
      end
    end

    within ".form-question", text: "What is the best videogame?" do
      within ".question-number" do
        page.should have_content '3'
      end
    end
  end

  def edit_fourth_question_and_reposition_it_to_before_first_question
    form = create :structure_research_form_a
    go_to_project "Project A"
    edit_form "Research Form A"
    within ".form-question-container", text: "Send email to?" do
      find('a', text: 'Edit').click
    end
    wait_for_modal_dialog

    within '.question-sequencing' do
      within '#sequence-dropdown' do
        select("As the first item")
      end
    end
    click_on "Save Question"
  end

  def see_repositioned_question_in_place_first_in_the_list
    within ".form-question", text: "Send email to?" do
      within ".question-number" do
        page.should have_content '1'
      end
    end

    within ".form-question", text: "What is your favorite color?" do
      within ".question-number" do
        page.should have_content '2'
      end
    end
  end

  def edit_third_question_and_reposition_it_to_after_second_question
    form = create :structure_research_form_a
    go_to_project "Project A"
    edit_form "Research Form A"
    within ".form-question-container", text: "Please leave this question blank" do
      find('a', text: 'Edit').click
    end
    wait_for_modal_dialog

    within '.question-sequencing' do
      within '#sequence-dropdown' do
        select('After 2: What is the best videogame?')
      end
    end
    click_on "Save Question"
  end

  def see_repositioned_question_in_place_after_second_question
    within ".form-question", text: "What is the best videogame?" do
      within ".question-number" do
        page.should have_content '2'
      end
    end

    within ".form-question", text: "Please leave this question blank" do
      within ".question-number" do
        page.should have_content '3'
      end
    end

    within ".form-question", text: "Send email to?" do
      within ".question-number" do
        page.should have_content '4'
      end
    end
  end

  def edit_third_question_and_reposition_it_to_before_second_question
    form = create :structure_research_form_a
    go_to_project "Project A"
    edit_form "Research Form A"
    within ".form-question-container", text: "Please leave this question blank" do
      find('a', text: 'Edit').click
    end
    wait_for_modal_dialog

    within '.question-sequencing' do
      within '#sequence-dropdown' do
        select('After 1: What is your favorite color?')
      end
    end
    click_on "Save Question"
  end

  def see_repositioned_question_in_place_before_old_second_question
    within ".form-question", text: "What is your favorite color?" do
      within ".question-number" do
        page.should have_content '1'
      end
    end

    within ".form-question", text: "Please leave this question blank" do
      within ".question-number" do
        page.should have_content '2'
      end
    end

    within ".form-question", text: "What is the best videogame?" do
      within ".question-number" do
        page.should have_content '3'
      end
    end
  end

  def create_a_new_question_and_reposition_it_to_after_fourth_question
    form = create :structure_research_form_a
    go_to_project "Project A"
    edit_form "Research Form A"
    start_form_question "Text Field", "varnew", "New Question"

    within '.question-sequencing' do

      within '#sequence-dropdown' do
        select('After 4: Send email to?')
      end
    end
    click_on "Save and Add Question"
    wait_for_modal_close
  end

  def create_a_new_question_and_reposition_it_to_before_second_question
    form = create :structure_research_form_a
    go_to_project "Project A"
    edit_form "Research Form A"
    start_form_question "Text Field", "varnew", "New Question"

    within '.question-sequencing' do
      expect(page).to have_select('sequence-dropdown', selected: 'As the first item')

      within '#sequence-dropdown' do
        select('After 1: What is your favorite color?')
      end
    end

    click_on "Save and Add Question"
    wait_for_modal_close
  end

  def create_form_with_formatting_questions
    create_new_form

    create_form_question "Text Field", "var4", "Fourth Question"
    create_form_question "Header", nil, "Header 2"
    create_form_question "Text Field", "var3", "Third Question"
    create_form_question "Header", nil, "Header 1"
    create_form_question "Checkbox", "var2", "Second Question" do
      enter_answer_option "Snap"
      enter_answer_option "Crackle"
      enter_answer_option "Pop"
    end
    create_form_question "Text Field", "var1", "First Question"

  end

  def see_form_builder_with_correct_sequence_numbers
    within ".form-question", text: "First Question" do
      within ".question-number" do
        page.should have_content '1'
      end
    end

    within ".form-question", text: "Second Question" do
      within ".question-number" do
        page.should have_content '2'
      end
    end

    within ".form-question", text: "Header 1" do
      page.should_not have_selector('.question-number')
    end

    within ".form-question", text: "Third Question" do
      within ".question-number" do
        page.should have_content '3'
      end
    end

    within ".form-question", text: "Header 2" do
      page.should_not have_selector('.question-number')
    end

    within ".form-question", text: "Fourth Question" do
      within ".question-number" do
        page.should have_content '4'
      end
    end
  end

  def see_new_question_before_second_question
    within ".form-question", text: "What is your favorite color?" do
      within ".question-number" do
        page.should have_content '1'
      end
    end

    within ".form-question", text: "New Question" do
      within ".question-number" do
        page.should have_content '2'
      end
    end

    within ".form-question", text: "What is the best videogame?" do
      within ".question-number" do
        page.should have_content '3'
      end
    end
  end

  def see_new_question_after_fourth_question
    within ".form-question", text: "Send email to?" do
      within ".question-number" do
        page.should have_content '4'
      end
    end

    within ".form-question", text: "New Question" do
      within ".question-number" do
        page.should have_content '5'
      end
    end
  end

  def see_form_entry_with_correct_sequence_numbers
    complete_form_and_enter_data

    within ".form-answer", text: "First Question" do
      find('.question-number').text.should == "1"
    end

    within ".form-answer", text: "Second Question" do
      find('.question-number').text.should == "2"
    end

    within ".form-answer", text: "Header 1" do
      page.should_not have_selector('.question-number')
    end

    within ".form-answer", text: "Third Question" do
      find('.question-number').text.should == "3"
    end

    within ".form-answer", text: "Fourth Question" do
      find('.question-number').text.should == "4"
    end
  end
end
