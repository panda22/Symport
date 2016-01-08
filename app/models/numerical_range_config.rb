class NumericalRangeConfig < ActiveRecord::Base
  belongs_to :form_question

  validates :precision, inclusion: { in: %w|0 1 2 3 4 5 6|,
    message: "%{value} is not a valid precision" }
end
