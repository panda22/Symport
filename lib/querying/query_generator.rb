class Querying::QueryGenerator
  class << self

    def select_attr_or_string(attribute, length = 1)
      return "" if (length == 0 || (length.to_i.to_s != length && length.to_i.to_s != length.to_s))
      
      chain = select_attr_string(attribute, 'none')
      for i in 2..length.to_i
        chain += select_attr_string(attribute, "or")
      end
      return chain
    end

    private

    def select_attr_string(attribute, andor = "none")
      if ["AND","OR"].include?((andor || "").upcase!)
        " " + andor + " " + attribute + " = ? "
      else
          " " + attribute + " = ? " 
      end
    end

  end
end