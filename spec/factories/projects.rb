FactoryGirl.define do
  factory :project_a, class: Project do
    name "Project A"
  end

  factory :project_b, class: Project do
    name "Project B"
  end

  factory :project do
    name "Research Project"
  end
end
