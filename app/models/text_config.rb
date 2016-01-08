class TextConfig < ActiveRecord::Base
  belongs_to :form_question

  validates :size, inclusion: { in: %w|normal large|,
    message: "%{value} is not a valid text size" }
end
