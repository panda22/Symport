class QueryComparator
  class << self

    def compare(operator, lhs, rhs)
      case operator
        when "="
          return (lhs == rhs)
        when "≠"
          return (lhs != rhs)
        when "<"
          if lhs == nil or rhs == nil
            return false
          end
          return (lhs < rhs)
        when ">"
          if lhs == nil or rhs == nil
            return false
          end
          return (lhs > rhs)
        when "≤"
          if lhs == nil or rhs == nil
            return false
          end
          return (lhs <= rhs)
        when "≥"
          if lhs == nil or rhs == nil
            return false
          end
          return (lhs >= rhs)
        when "contains"
          if lhs == nil or rhs == nil
            return false
          end
          return (lhs.include?(rhs))
        when "does not contain"
          if lhs == nil or rhs == nil
            return false
          end
          return !(lhs.include?(rhs))
        else
          return false
      end
    end

    def compare_wildcard(operator, lhs, rhs)
      if lhs == nil or lhs == "" or rhs == nil or rhs == ""
        return false
      end
      is_equal = (operator == "=")
      ret_val = nil
      if lhs.length != rhs.length
        return !is_equal
      end
      (0...lhs.length).each do |i|
        if lhs[i] == "#" or rhs[i] == "#" or lhs[i] == "/" or rhs[i] == "/"
          next
        end
        if lhs[i] != rhs[i]
          if is_equal
            return false
          else
            ret_val = true
          end
        end
        if lhs[i] == rhs[i]
          if is_equal
            ret_val = true
          end
        end
      end

      if ret_val.nil?
        is_equal
      else
        ret_val
      end
    end

    def compare_date_exception(operator, exception_value, rh_value, exception_obj)
      if exception_obj[:year]
        return false
      end
      exception_parts = exception_value.split("/")
      normal_parts = rh_value.split("/")
      if exception_parts.length != 3 or normal_parts.length != 3
        return false
      end
      exception_day = exception_parts[1]
      exception_month = exception_parts[0]
      exception_year = exception_parts[2]
      exception_date = get_date_from_exception(operator,
                                               exception_day,
                                               exception_month,
                                               exception_year,
                                               exception_obj[:month],
                                               exception_obj[:day])
      rh_date = Date.strptime(rh_value, "%m/%d/%Y") rescue nil
      if exception_date == nil or rh_date == nil
        return false
      end
      case operator
        when "<"
          return exception_date < rh_date
        when "≤"
          return exception_date <= rh_date
        when ">"
          return exception_date > rh_date
        when "≥"
          return exception_date >= rh_date
        else
          return false
      end
    end

    def get_date_from_exception(operator, day, month, year, is_month_exception, is_day_exception)
      new_year = year.to_i
      begin
        case operator
          when "<", "≤"
            if is_month_exception and is_day_exception
              return Date.strptime("12/31/#{new_year}", "%m/%d/%Y")
            elsif is_day_exception
              new_month = month.to_i
              return Date.strptime("#{new_month}/1/#{new_year}", "%m/%d/%Y").end_of_month
            elsif is_month_exception
              new_day = day.to_i
              return Date.strptime("12/#{new_day}/#{new_year}", "%m/%d/%Y")
            else
              return nil
            end
          when ">", "≥"
            if is_month_exception and is_day_exception
              return Date.strptime("1/1/#{new_year}", "%m/%d/%Y")
            elsif is_day_exception
              new_month = month.to_i
              return Date.strptime("#{new_month}/1/#{new_year}", "%m/%d/%Y")
            elsif is_month_exception
              new_day = day.to_i
              return Date.strptime("1/#{new_day}/#{new_year}", "%m/%d/%Y")
            end
          else
            nil
        end
      rescue
        nil
      end
    end

  end
end