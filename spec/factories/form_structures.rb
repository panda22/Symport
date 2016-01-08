FactoryGirl.define do
  factory :structure_research_form_a, class: FormStructure do
    name "Research Form A"
    after :create do |structure, evaluator|
      structure.update_attributes! project: create(:project_a)
      create :question_favorite_color, form_structure: structure
      create :question_leave_blank, form_structure: structure
      create :question_videogame, form_structure: structure
      create :question_send_email, form_structure: structure
    end
  end

  factory :structure_research_form_b, class: FormStructure do
    name "Research Form B"
    after :create do |structure, evaluator|
      structure.update_attributes! project: create(:project_b)
      create :question_name, form_structure: structure
      create :question_age, form_structure: structure
      create :question_date_of_birth, form_structure: structure
      create :question_checking_the_clock, form_structure: structure
    end
  end

  factory :form_structure do
    project
    name "Form"
    after :create do |structure, evaluator|
      create :question_favorite_color, form_structure: structure
      create :question_name, form_structure: structure
    end
  end

  factory :empty_form_structure, class: FormStructure do
    project
    name "Form"
  end
end
