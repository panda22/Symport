class QueryOrderer
  class << self
    def order(queries, order_type)
      case order_type
        when "editedDescending"
          return queries.sort do |a, b|
            b.updated_at <=> a.updated_at
          end
        when "editedAscending"
          return queries.sort do |a, b|
            a.updated_at <=> b.updated_at
          end
        when "a-z"
          return queries.sort do |a, b|
            a.name.upcase <=> b.name.upcase
          end
        when "z-a"
          return queries.sort do |a, b|
            b.name.upcase <=> a.name.upcase
          end
        else # defaults to "editedDescending"
          return queries.sort do |a, b|
            b.updated_at <=> a.updated_at
          end
      end
    end
  end
end