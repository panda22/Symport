FactoryGirl.define do

  factory :form_response do
    form_structure
  end

  factory :response_research_form_a, class: FormResponse do

    subject_id "abc123"
    instance_number 0

    after :create do |response, evaluator|
      struc = create(:structure_research_form_a)
      response.update_attributes! form_structure: struc
      response.form_answers = [
        create_answer(:answer_favorite_color, struc),
        create_answer(:answer_leave_blank, struc),
        create_answer(:answer_videogame, struc),
        create_answer(:answer_send_email, struc)
      ]
    end
  end

  factory :response_research_form_b, class: FormResponse do

    subject_id "cba321"
    instance_number 0

    after :create do |response, evaluator|
      struc = create(:structure_research_form_b)
      response.update_attributes! form_structure: struc
      response.form_answers = [
        create_answer(:answer_name, struc),
        create_answer(:answer_age, struc),
        create_answer(:answer_date_of_birth, struc),
        create_answer(:answer_checking_the_clock, struc)
      ]
    end
  end
end
