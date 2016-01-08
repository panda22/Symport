class QueryParam < ActiveRecord::Base
	belongs_to :query
	belongs_to :form_question
	belongs_to :form_structure
end
