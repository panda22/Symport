# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name "Random"
    last_name "Guy"
    password "abcd1234"
    phone_number "1234567890"
  end

end
