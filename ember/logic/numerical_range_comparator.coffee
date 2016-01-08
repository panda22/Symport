LabCompass.NumericalRangeComparator = LabCompass.NumericComparator.extend

  compute: (operator, lefthandStr, righthandStr) ->
    lefthand = parseFloat(lefthandStr)
    righthand = parseFloat(righthandStr)
    @_super(operator, lefthand, righthand)

