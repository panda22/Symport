class Query < ActiveRecord::Base
	acts_as_paranoid
	has_many :query_params
	has_many :query_form_structures
	belongs_to :owner, class_name: "User"
	belongs_to :editor, class_name: "User"
	belongs_to :project

	validates :name, presence: { message: "Please enter a name" }
end
