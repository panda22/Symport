describe "manage subject id" do

  before do
    log_in_as_test_user
    create_new_project "Manage"
    create_new_form_within_project "Form A"
    go_to_project "Manage"
    create_new_form_within_project "Form B"

    edit_response_for "Manage", "Form A", "barney"
    submit_form

    edit_response_for "Manage", "Form B", "barney"
    submit_form
  end

  it "allows changing of subject ID and changes it project wide" do
    # edit one of the responses for that subject ID

    edit_response_for "Manage", "Form A", "barney"

    # rename the subject ID
    rename_subject_id "fred"

    # see that the page is updated with the new subject ID
    see_editing_response_for_subject_id "fred"

    # see that the combo box for selecting subject IDs only contains the new ID, not old

    # switch to the response for the other form and see the subject ID is correct
    edit_response_for "Manage", "Form B", "fred"
    see_response_is_not_new
  end

  it "allows deleting of subject ID and deletes it project wide" do
    edit_response_for "Manage", "Form A", "barney"

    delete_current_response confirm: false
    see_editing_response_for_subject_id "barney"

    delete_current_response confirm: true
    see_not_editing_response

    edit_response_for "Manage", "Form A", "this doesn't exist in the database"

    delete_current_response

    see_not_editing_response
  end

end
