class FormAnswer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :form_response
  belongs_to :form_question
end
