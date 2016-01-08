describe 'download form responses' do
  it 'downloads data with phi' do
    create_form_and_responses_with_phi
    download_form_including_phi
    verify_downloaded_response_with_phi
  end

  it 'downloads data without phi' do
    create_form_and_responses_with_phi
    download_form_without_phi
    verify_downloaded_response_without_phi
  end

  def create_form_and_responses_with_phi
    create :response_research_form_a
  end

  def download_form_including_phi
    start_download_form
    within_modal do
      within ".phiContainer" do
        within ".yes-radio" do
          find("input").click()
        end
      end
      click_on "Download Data"
    end
    wait_for_modal_close
  end

  def download_form_without_phi
    start_download_form
    within_modal do
      within ".phiContainer" do
        within ".no-radio" do
          find("input").click()
        end
      end
      click_on "Download Data"
    end
    wait_for_modal_close
  end

  def start_download_form
    log_in_as_test_user
    go_to_project "Project A"
    in_project_form "Research Form A" do
      click_on "Download Data"
    end
    wait_for_modal_dialog
  end

  def verify_downloaded_response_with_phi
    page.body.should == "\"Subject ID\",\"my_variable_name_1\",\"my_variable_name_3\",\"my_variable_name_2\",\"my_variable_name_4\"\n\"abc123\",\"Green\",\"Super Metroid\",\"\",\"foo@bar.com\""
  end

  def verify_downloaded_response_without_phi
    page.body.should == "\"Subject ID\",\"my_variable_name_3\",\"my_variable_name_2\"\n\"abc123\",\"Super Metroid\",\"\""
  end
end
