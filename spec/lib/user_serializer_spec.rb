describe UserSerializer do
  subject { described_class }

  describe ".serialize" do

    it "writes out a user with relevant fields" do
      user = User.new(
        email: "something@somewhere.com",
        first_name: "bat",
        last_name: "man",
        affiliation: "stuff",
        phone_number: "1234567890",
        field_of_study: "chiropterology",
        password: "b4tm4n",
        password_confirmation: "b4tm4n"
      )

      stuff = subject.serialize user
      stuff.should == {
        email: "something@somewhere.com",
        firstName: "bat",
        lastName: "man",
        phoneNumber: "1234567890",
        affiliation: "stuff",
        fieldOfStudy: "chiropterology",
        demoProgress: 0
      }
    end

  end

end
