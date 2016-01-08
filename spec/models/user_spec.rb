require 'spec_helper'

describe User do

  describe "validating password" do
    it "requires min length of 8" do
      user = User.new email: "foo@bar.com", first_name: "First", last_name: "Last", phone_number: "1234567890"
      expect { user.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Password can't be blank/
      }
      user.password = "Short1"
      expect { user.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Password Please enter a password matching conditions to the right/
      }
      user.password = "Complex1"
      expect { user.save! }.not_to raise_error 
    end

    it "requires one capital-letter" do
      user = User.new email: "foo@bar.com", first_name: "First", last_name: "Last", password: "lowercase1", phone_number: "1234567890"
      expect { user.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Password Please enter a password matching conditions to the right/
      }
      user.password = "Lowercase1"
      expect { user.save! }.not_to raise_error 
    end

    it "requires one lowercase-letter" do
      user = User.new email: "foo@bar.com", first_name: "First", last_name: "Last", password: "UPPERCASE1", phone_number: "1234567890"
      expect { user.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Password Please enter a password matching conditions to the right/
      }
      user.password = "uPPERCASE1"
      expect { user.save! }.not_to raise_error 
    end

    it "requires one number" do
      user = User.new email: "foo@bar.com", first_name: "First", last_name: "Last", password: "SuperComplex", phone_number: "1234567890"
      expect { user.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Password Please enter a password matching conditions to the right/
      }
      user.password = "SuperComplex1"
      expect { user.save! }.not_to raise_error 
    end

  end

  it "requires email in correct format" do
    user = User.new first_name: "First", last_name: "Last", password: "Complex1", phone_number: "1234567890"
    expect { user.save! }.to raise_error { |err|
      err.class.should == ActiveRecord::RecordInvalid
      err.message.should =~ /Email addresses should be in the format example@xyz.com/
    }
    user.email = "not_an_email"
    expect { user.save! }.to raise_error { |err|
      err.class.should == ActiveRecord::RecordInvalid
      err.message.should =~ /Email addresses should be in the format example@xyz.com/
    }
    user.email = "valid@address.com"
    expect { user.save! }.not_to raise_error 
  end

  it "requires first name" do
    user = User.new email: "valid@addr.com", last_name: "Last", password: "Complex1", phone_number: "1234567890"
    expect { user.save! }.to raise_error { |err|
      err.class.should == ActiveRecord::RecordInvalid
      err.message.should =~ /Please tell us your first name/
    }
    user.first_name = "A"
    expect { user.save! }.not_to raise_error 
  end

  it "requires last name" do
    user = User.new email: "valid@addr.com", first_name: "Last", password: "Complex1", phone_number: "1234567890"
    expect { user.save! }.to raise_error { |err|
      err.class.should == ActiveRecord::RecordInvalid
      err.message.should =~ /Please tell us your last name/
    }
    user.last_name = "A"
    expect { user.save! }.not_to raise_error 
  end

end
