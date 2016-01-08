# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pending_user do
    user_id ""
    team_member_id ""
    expires ""
    message "MyText"
  end
end
