class FormQuestionCondition < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :form_question
  belongs_to :depends_on, class_name: "FormQuestion"

  validates :operator, inclusion: { in: ["<", "<=", "=", ">=", ">", "<>"],
    message: "%{value} is not a valid conditional operator" }

  validates :form_question, presence: true
  validates :depends_on, presence: true
  validates_with FormQuestionConditionValidator, fields: [:form_question, :depends_on]
end
