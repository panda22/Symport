class AuditLog < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :form_question
  belongs_to :form_structure
  belongs_to :form_structure_permission
  belongs_to :project
  belongs_to :team_member
  belongs_to :user

  # TODO some fancy rails syntax
  def form_response
    form_structure.try(:form_responses).try(:find_by, subject_id: subject_id)
  end

  def form_answer 
    form_response.try(:form_answers).try(:find_by, form_question: form_question)
  end

  validates :action, inclusion: { in: ["add", "edit", "remove", "view", "export", "import", "sign_in", "sign_in_failed", "sign_out"],
    message: "%{value} is not a valid action type" }
end
