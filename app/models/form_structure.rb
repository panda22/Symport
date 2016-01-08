class FormStructure < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :project
  has_many :form_questions
  has_many :form_responses
  has_many :form_structure_permissions
  has_many :option_configs, through: :form_questions
  has_many :numerical_range_configs, through: :form_questions
  has_many :form_question_conditions, through: :form_questions
  has_many :question_exceptions, through: :form_questions

  has_many :answerable_questions, -> { where.not(question_type: QuestionTypes.formatting_types)}, class_name: "FormQuestion"

  validates :name, presence: { message: "Please name your form" }, uniqueness_without_deleted: { scope: :project, message: "Please make your form name unique" }
  validates :secondary_id, allow_nil: true, :if => lambda { |o| o.is_many_to_one == false },
              allow_nil: false, :if => lambda { |o| o.is_many_to_one == true },
              presence: { message: "Please enter a name for your secondary ID" },
              uniqueness_without_deleted: { scope: :project, message: "This secondary ID name is already exists in this project. Please make it unique.",
                :if => lambda { |o| o.is_many_to_one == true }  }
end
