FactoryGirl.define do

  factory :question, class: FormQuestion do
    question_type "text"
    prompt "Who cares?"
    sequence_number 111
    display_number "111"
    variable_name SecureRandom.uuid.to_s.gsub("-", "00")
    association :text_config, factory: :text_config, size: 'large'
  end

  factory :question_favorite_color, class: FormQuestion do
    personally_identifiable true
    prompt "What is your favorite color?"
    question_type "text"
    variable_name "my_variable_name_1"
    sequence_number 1
    display_number "1"
    association :text_config, factory: :text_config, size: 'normal'
  end

  factory :question_leave_blank, class: FormQuestion do
    personally_identifiable false
    prompt "Please leave this question blank"
    question_type "date"
    variable_name "my_variable_name_2"
    sequence_number 3
    display_number "3"
  end

  factory :question_videogame, class: FormQuestion do
    personally_identifiable false
    prompt "What is the best videogame?"
    question_type "text"
    sequence_number 2
    display_number "2"
    variable_name "my_variable_name_3"
    association :text_config, factory: :text_config, size: 'normal'
  end

  factory :question_send_email, class: FormQuestion do
    personally_identifiable true
    prompt "Send email to?"
    question_type "email"
    variable_name "my_variable_name_4"
    sequence_number 4
    display_number "4"
  end

  factory :question_name, class: FormQuestion do
    personally_identifiable true
    prompt "Name:"
    question_type "text"
    variable_name "my_variable_name_5"
    sequence_number 1
    display_number "1"
    association :text_config, factory: :text_config, size: 'large'
  end

  factory :question_age, class: FormQuestion do
    personally_identifiable true
    prompt "Age:"
    question_type "numericalrange"
    variable_name "my_variable_name_6"
    sequence_number 2
    display_number "2"
    association :numerical_range_config, factory: :numerical_range_config, minimum_value: 10, maximum_value: 120, precision: '0'
  end

  factory :question_date_of_birth, class: FormQuestion do
    personally_identifiable true
    prompt "Date of birth"
    question_type "date"
    variable_name "my_variable_name_7"
    sequence_number 3
    display_number "3"
  end

  factory :question_checking_the_clock, class: FormQuestion do
    personally_identifiable true
    prompt "Checking the clock"
    question_type "timeofday"
    variable_name "my_variable_name_8"
    sequence_number 4
    display_number "4"
  end

  factory :numerical_range_config do
    minimum_value 0
    maximum_value 10
    precision '1'
  end

  factory :text_config do
    size 'large'
  end

end
