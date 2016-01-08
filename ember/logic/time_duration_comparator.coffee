LabCompass.TimeDurationComparator = LabCompass.NumericComparator.extend

  compute: (operator, lefthandStr, righthandStr) ->
    groups = lefthandStr.split(":")
    lefthand = groups[0] * 60 * 60 + groups[1] * 60 + groups[2]
    groups = righthandStr.split(":")
    righthand = groups[0] * 60 * 60 + groups[1] * 60 + groups[2]
    @_super(operator, lefthand, righthand)

