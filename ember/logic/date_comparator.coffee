LabCompass.DateComparator = LabCompass.NumericComparator.extend

  month_max_day: {1: 31, 2: 28, 3: 31, 4: 30, 5: 31, 6: 30, 7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31}

  compute: (operator, lefthand, righthand) ->
    if lefthand && righthand
      if operator == "=" 
      	@dates_equal(lefthand, righthand)
      else if operator == "<>"
      	@dates_not_equal(lefthand, righthand)
      else if operator == "<"
        @date_less_than(lefthand, righthand) 
      else if operator == "<="
        @date_less_than(lefthand, righthand, true) 
      else if operator == ">"
        @date_greater_than(lefthand, righthand)
      else if operator == ">="
        @date_greater_than(lefthand, righthand, true) 
    else
      false
  
  date_greater_than: (lhs, rhs, orequal=false) ->
    MONTH_MAX_DAY = @get("month_max_day")
    match = /^(\d{1,2})\/(\d{1,2})\/(\d{1,4})$/.exec lhs
    if !match
      return false
    year = parseInt match[3]
    month = parseInt match[1]
    day = parseInt match[2]
    if year > 2500 
      return false;
    if month > 12 || month < 1
      month = 1
    if day < 1 || day > MONTH_MAX_DAY[month]
      day = 1

    l = new Date(month+"/"+day+"/"+year).getTime()
    r = new Date(rhs).getTime()
    return l > r || (l == r && orequal)


  date_less_than: (lhs, rhs, orequal=false) ->
    MONTH_MAX_DAY = @get("month_max_day")
    match = /^(\d{1,2})\/(\d{1,2})\/(\d{1,4})$/.exec lhs
    if !match
      return false
    year = parseInt match[3]
    month = parseInt match[1]
    day = parseInt match[2]
    if year > 2500 
      return false;
    if month > 12 || month < 1
      month = 12
    if day < 1 || day > MONTH_MAX_DAY[month]
      day = MONTH_MAX_DAY[month]
    
    l = new Date(month+"/"+day+"/"+year).getTime()
    r = new Date(rhs).getTime()
    return l < r || (l == r && orequal)

  dates_equal: (lhs, rhs) -> #lhs = answer    rhs = cond. valu
    if lhs.length != rhs.length
      return false
    i = 0
    for c in rhs
      if lhs[i++] != c && c != "#"
        return false
    return true

  dates_not_equal: (lhs, rhs) -> #lhs = answer    rhs = cond. valu
    if lhs.length != rhs.length
      return false
    i = 0
    equal = true

    for c in rhs
      if lhs[i++] != c && c != "#"
        equal = false
    if equal
      return false
    return true