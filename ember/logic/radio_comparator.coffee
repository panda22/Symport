LabCompass.RadioComparator = LabCompass.EqualityComparator.extend

  compute: (operator, lefthand, righthand) ->
    if lefthand && righthand
      lefthandValue = lefthand.split("\u200a")[0]
      @_super operator, lefthandValue, righthand
    else
      false

