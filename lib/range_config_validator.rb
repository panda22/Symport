class RangeConfigValidator < ActiveModel::Validator
	def validate(record)
	    #if "numericalrange" == record.question_type
	    #    if record.numerical_range_config.minimum_value == nil
	    #        record.errors.add(:numerical_range_config_min, 'Enter Valid Number')
	    #    end
	    #    if record.numerical_range_config.maximum_value == nil
	    #        record.errors.add(:numerical_range_config_max, 'Enter valid number')
	    #    end
	    #end
    end
end