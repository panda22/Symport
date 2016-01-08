LabCompass.TimeOfDayComparator = LabCompass.NumericComparator.extend

  compute: (operator, lefthand, righthand) ->
    if lefthand && righthand
      if (new Date("1/1/2000 #{righthand}").toDateString() != "Invalid Date")
        @_super operator, new Date("1/1/2001 #{lefthand}").getTime(), new Date("1/1/2001 #{righthand}").getTime()
      else
        if operator == "=" 
          @times_equal(lefthand, righthand)
        else if operator == "<>"
          @times_not_equal(lefthand, righthand)
        else
          @_super operator, new Date("1/1/2001 #{lefthand}").getTime(), new Date("1/1/2001 #{righthand}").getTime()
    else
      false

  times_equal: (lhs, rhs) -> #lhs = answer    rhs = cond. valu
    lhs.slice(0,lhs.length-3) == rhs.slice(0,rhs.length-3)

  times_not_equal: (lhs, rhs) -> #lhs = answer    rhs = cond. valu
    lhs.slice(0,lhs.length-3) != rhs.slice(0,rhs.length-3)