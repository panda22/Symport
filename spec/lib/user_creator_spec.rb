describe UserCreator do
  subject { described_class }

  describe ".create" do

    before do
      AuditLogger.stubs(:add)
    end

    it "takes params hash full of data from the JSON we expect and creates a user" do
      user = subject.create(
        "email" => "chris@chrisfarber.net",
        "firstName" => "Chris",
        "lastName" => "Farber",
        "phoneNumber" => "1234567890",
        "affiliation" => "Atomic Object",
        "fieldOfStudy" => "Computer Science",
        "password" => "Complex1",
        "passwordConfirmation" => "Complex1"
      )

      user.should_not be_nil

      user.reload.email.should == "chris@chrisfarber.net"
    end

    it "rejects to create user with an invalid email address" do
      expect do
          subject.create(
            "email" => "david@QORASHI",
            "firstName" => "David",
            "lastName" => "Qorashi",
            "phoneNumber" => "1234567890",
            "affiliation" => "Atomic Object",
            "fieldOfStudy" => "Computer Science",
            "password" => "Complex1",
            "passwordConfirmation" => "Complex1"
          )
      end.to raise_error ActiveRecord::RecordInvalid
    end

    it "removes leading and trailing spaces from the email" do
      user = subject.create(
        "email" => "   david@QORASHI.com   ",
        "firstName" => "David",
        "lastName" => "Qorashi",
        "affiliation" => "Atomic Object",
        "fieldOfStudy" => "Computer Science",
        "phoneNumber" => "1234567890",
        "password" => "Complex1",
        "passwordConfirmation" => "Complex1"
      )

      user.should_not be_nil

      user.reload.email.should == "david@qorashi.com"
    end

    it "coverts email address to lowercase before creating a user" do
      user = subject.create(
        "email" => "david@QORASHI.com",
        "firstName" => "David",
        "lastName" => "Qorashi",
        "affiliation" => "Atomic Object",
        "phoneNumber" => "1234567890",
        "fieldOfStudy" => "Computer Science",
        "password" => "Complex1",
        "passwordConfirmation" => "Complex1"
      )

      user.should_not be_nil

      user.reload.email.should == "david@qorashi.com"
    end

    it 'logs user creation' do
      AuditLogger.expects(:add).with do |editor, user|
        editor == user && editor.first_name == "Chris"
      end
      user = subject.create(
        "email" => "chris@chrisfarber.net",
        "firstName" => "Chris",
        "lastName" => "Farber",
        "phoneNumber" => "1234567890",
        "password" => "Complex1",
        "passwordConfirmation" => "Complex1"
      )

      user.should_not be_nil

      user.reload.email.should == "chris@chrisfarber.net"
    end

    it "throws payload exception when email is already registered" do
      first = create :user, email: "an@email.com", password: "Complex1"

      begin
        subject.create("email" => "an@email.com", "phoneNumber" => "1234567890", "password" => "Complex1", "firstName" => "David", "lastName" => "Tennant", "passwordConfirmation" => "Complex1")
      rescue PayloadException => ex
        payload_exception = ex
      end

      payload_exception.should be_a PayloadException
      payload_exception.error.should == "{\"validations\":{\"email\":[\"An account has already been registered for this e-mail address\"]}}"
 
    end

    it "throws an error when password confirmation is missing" do
      begin
        subject.create("email" => "arbitrary@address.com", "password" => "Complex1")
      rescue Exception => ex
        exception = ex
      end

      exception.should be
    end

  end

end
