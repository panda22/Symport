class GenericRecordErrorsSerializer
  class << self
    def validation_errors(structure)
      validations = {}

      structure.errors.each do |prop_name, error|
        camel_name = prop_name.to_s.camelize :lower
        messages = validations[camel_name] ||= []
        messages << error
      end

      validations

    end
  end
end