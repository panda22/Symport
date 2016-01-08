class QueryFormStructure < ActiveRecord::Base
  belongs_to :form_structure
  belongs_to :query
end
