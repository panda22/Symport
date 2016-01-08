FactoryGirl.define do
  factory :answer, class: FormAnswer do
  end

  factory :answer_favorite_color, class: FormAnswer do
    answer "Green"
    after :create do |answer, evaluator|
     answer.update_attributes! form_question: create(:question_favorite_color)
   end
  end

  factory :answer_leave_blank, class: FormAnswer do
    # answer "1/18/1981"
    after :create do |answer, evaluator|
      answer.update_attributes! form_question: create(:question_leave_blank)
    end
  end

  factory :answer_videogame, class: FormAnswer do
    answer "Super Metroid"
    after :create do |answer, evaluator|
      answer.update_attributes! form_question: create(:question_videogame)
    end
  end

  factory :answer_send_email, class: FormAnswer do
    answer "foo@bar.com"
    after :create do |answer, evaluator|
      answer.update_attributes! form_question: create(:question_send_email)
    end
  end

  factory :answer_name, class: FormAnswer do
    answer "Inigo Montoya"
    after :create do |answer, evaluator|
      answer.update_attributes! form_question: create(:question_name)
    end
  end

  factory :answer_age, class: FormAnswer do
    answer "28"
    after :create do |answer, evaluator|
      answer.update_attributes! form_question: create(:question_age)
    end
  end

  factory :answer_date_of_birth, class: FormAnswer do
    answer "1/8/1986"
    after :create do |answer, evaluator|
      answer.update_attributes! form_question: create(:question_date_of_birth)
    end
  end

  factory :answer_checking_the_clock, class: FormAnswer do
    answer "08:34 PM"
    after :create do |answer, evaluator|
      answer.update_attributes! form_question: create(:question_checking_the_clock)
    end
  end
end
