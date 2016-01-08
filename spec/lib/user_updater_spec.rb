describe UserUpdater do
  subject { described_class }

  describe ".update" do
    before do
      AuditLogger.stubs(:surround_edit).yields
    end

    it "updates the user" do
      user = mock "user"
      user.stubs(:authenticate).returns user

      user.expects(:update_attributes!).with(
        first_name: "hot cheetos",
        last_name: "and takis",
        affiliation: "not very good",
        phone_number: "1234567890",
        field_of_study: "culinary arts",
        last_viewed_project: nil,
        demo_progress: nil,
        last_viewed_page: nil,
        password: "new passwd",
        password_confirmation: "new passwd confirmation"
      )

      subject.update user, {
        "email" => "don't change me bro",
        "firstName" => "hot cheetos",
        "lastName" => "and takis",
        "affiliation" => "not very good",
        "phoneNumber" => "1234567890",
        "fieldOfStudy" => "culinary arts",
        "lastViewedProject" => nil,
        "lastViewedPage" => nil,
        "password" => "new passwd",
        "passwordConfirmation" => "new passwd confirmation"
      }
    end

    it "doesn't update the password if the password is empty" do
      user = mock "user"
      user.stubs(:authenticate).returns user

      user.expects(:update_attributes!).with(
        first_name: "hot cheetos",
        last_name: "and takis",
        affiliation: "not very good",
        phone_number: "1234567890",
        field_of_study: "culinary arts",
        last_viewed_project: nil,
        demo_progress: nil,
        last_viewed_page: nil
      )

      subject.update user, {
        "email" => "don't change me bro",
        "firstName" => "hot cheetos",
        "lastName" => "and takis",
        "phoneNumber" => "1234567890",
        "affiliation" => "not very good",
        "fieldOfStudy" => "culinary arts",
        "password" => "",
        "passwordConfirmation" => "",
      }
    end

    it "forces the passwordConfirmation to an empty string if password is specified" do
      user = mock "user"
      user.stubs(:authenticate).returns user


      user.expects(:update_attributes!).with(
        first_name: "hot cheetos",
        last_name: "and takis",
        affiliation: "not very good",
        phone_number: "1234567890",
        field_of_study: "culinary arts",
        password: "yams",
        password_confirmation: "",
        last_viewed_project: nil,
        demo_progress: nil,
        last_viewed_page: nil
      )

      subject.update user, {
        "email" => "don't change me bro",
        "firstName" => "hot cheetos",
        "lastName" => "and takis",
        "affiliation" => "not very good",
        "phoneNumber" => "1234567890",
        "fieldOfStudy" => "culinary arts",
        "password" => "yams",
        "passwordConfirmation" => nil,
      }
    end

    it "requires the current password to be correct in order to update the password" do
      user = User.create! email: "stuff@stuff.com", first_name: "fn", last_name: "ln", password: "Complex1", phone_number: "1234567890"

      user.expects(:authenticate).with("Complex2").returns false

      begin
        subject.update user, {
          "email" => "don't change me bro",
          "firstName" => "hot cheetos",
          "lastName" => "and takis",
          "affiliation" => "not very good",
          "phoneNumber" => "1234567890",
          "fieldOfStudy" => "culinary arts",
          "currentPassword" => "Complex2",
          "password" => "yams",
          "passwordConfirmation" => "yams",
        }
      rescue ActiveRecord::RecordInvalid => ex
        exception = ex
      end

      exception.should be
      exception.record.errors["current_password"].should == ["Current password is incorrect"]
    end

    it "logs updates to user account" do
      user = mock "user"
      user.stubs(:authenticate).returns user

      user.expects(:update_attributes!)

      AuditLogger.expects(:surround_edit).with(user, user).yields

      subject.update user, {
        "email" => "don't change me bro",
        "firstName" => "hot cheetos",
        "phoneNumber" => "1234567890",
        "lastName" => "and takis",
        "password" => "new passwd",
        "passwordConfirmation" => "new passwd confirmation"
      }
    end
  end

end
