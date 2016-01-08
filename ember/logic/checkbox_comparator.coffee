LabCompass.CheckboxComparator = LabCompass.ContainsComparator.extend

  compute: (operator, lefthand, righthand) ->
    if lefthand && righthand
      lefthandValues = lefthand.split("\u200C")
      lefthandValues = lefthandValues.map (value)->
      	i = value.indexOf("\u200a")
      	if i > -1
      		value.slice(0, i)
      	else
      		value
      @_super operator, lefthandValues, righthand
    else
      false

