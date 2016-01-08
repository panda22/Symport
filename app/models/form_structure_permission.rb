class FormStructurePermission < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :form_structure
  belongs_to :team_member

  validates :permission_level, inclusion: { in: Permissions.form_structure_permission_levels,
    message: "%{value} is not a valid Form permission level" }

  validates :team_member, uniqueness_without_deleted: {scope: :form_structure}
end
