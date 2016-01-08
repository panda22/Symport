# orders many to one responses for a form on secondary id
class FormResponseOrderer
  class << self
  	def order(response_record)
  		instances = FormResponse.where(
  			:form_structure_id => response_record.form_structure_id,
  			:subject_id => response_record.subject_id
  		)
			form = FormStructure.find(response_record.form_structure_id)
			ordered_instances = nil
			if form.is_many_to_one and form.is_secondary_id_sorted
				ordered_instances = instances.sort do |lhs, rhs|
					if lhs.secondary_id.nil? or rhs.secondary_id.nil?
						lhs.instance_number <=> rhs.instance_number
					else
					 lhs.secondary_id <=> rhs.secondary_id
					end
				end
			elsif form.is_many_to_one and form.is_secondary_id_sorted == false
				ordered_instances = instances.sort do |lhs, rhs|
					lhs.created_at <=> rhs.created_at
				end
			else
				ordered_instances = instances
			end

			ordered_instances.map.with_index do |response, i|
  			response.instance_number = i
  			response
  		end
  		ordered_instances.each do |response|
  			response.save!(:validate => false) # ensures no collision of instance number errors
  		end
  	end
  end
end