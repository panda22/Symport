class Project < ActiveRecord::Base
  acts_as_paranoid

  has_many :project_backups
  has_many :form_structures
  has_many :form_structure_permissions, through: :form_structures
  has_many :form_questions, through: :form_structures
  has_many :option_configs, through: :form_questions
  has_many :form_question_conditions, through: :form_questions
  has_many :team_members
  has_many :administrators, -> { where administrator: true }, class_name: "TeamMember"
  has_many :users, through: :team_members
  has_many :form_responses, through: :form_structures

  validates :name, presence: { message: "Please name your project" }
end
