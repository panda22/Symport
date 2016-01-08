class FormResponse < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :form_structure
  has_many :form_answers
  has_many :form_questions, through: :form_answers
  self.per_page = 20

  validates :subject_id, presence: { message: "must be specified" }, uniqueness_without_deleted: { scope: [:form_structure, :instance_number], message: 'A response already exists for subject "%{value}" with the same instance_number' }
  validates :secondary_id, allow_nil: true, :if => lambda { |o| 
                                                            if o.form_structure_id.nil?
                                                              return true
                                                            end 
                                                            o.form_structure.is_many_to_one == false 
                                                          },
              allow_nil: false, :if => lambda { |o| 
                                                if o.form_structure_id.nil?
                                                  return false
                                                end 
                                                o.form_structure.is_many_to_one == true 
                                              },
            	length: {minimum: 1, message: "must be specified"}, uniqueness_without_deleted: { scope: [:form_structure, :subject_id], message: 'A response already exists with Secondary ID "%{value}" for this subject' }
  validates :instance_number, uniqueness_without_deleted: { scope: [:form_structure, :subject_id], message: 'A response already exists with Secondary ID "%{value}" for this subject' }
end
