class DemoProgress < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :project
  
end
