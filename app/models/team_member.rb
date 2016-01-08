class TeamMember < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :project
  belongs_to :user
  has_many :form_structure_permissions, dependent: :destroy

  validates :user, uniqueness_without_deleted: {scope: :project}


  def expired?
    is_expired = false
    if self.present? && self.expiration_date.present?
      is_expired = self.expiration_date < Time.now
    end
    is_expired
  end
end
