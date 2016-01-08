class QuestionException < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :form_question

  validates :exception_type, inclusion: { in: ["zipcode", "numericalrange", "timeofday", "email", "date_day", "date_month", "date_year"],
    message: "%{value} is not a valid exception type" }

  #validates :value, :presence => {:message => "Please enter a code"}
  #validates :label, :presence => {:message => "Please enter a label"}

  #validates_with QuestionExceptionValidator, fields: [:value, :exception_type]
end