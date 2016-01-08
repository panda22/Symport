class ShallowRecordSerializer
  class << self
    def serialize(record, *attrs)
      attrs = attrs.map(&:to_s)
      record.attributes.slice(*attrs).reduce({}) do |hash, pair|
        unless pair[1].nil?
          hash[pair[0].camelize(:lower).to_sym] = pair[1]
        end
        hash
      end
    end
  end
end
