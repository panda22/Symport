#numerical-range-field
#used by AnswerTypeSpecificUI for numercal range type answers 
LabCompass.NumericalRangeFieldComponent = Ember.Component.extend

  classNames: ["number-field"]

  instructionString: ( ->
    no_min = Ember.isEmpty(@get('constraints.minValue'))
    no_max = Ember.isEmpty(@get('constraints.maxValue'))

    str = ""
    prec = @get('constraints.precision')
    
    if prec == 0 
      str = "Enter a whole number"
    else if prec == 6
      str = "Enter any number"
    else if prec == 1
      str = "Enter a number with at least " + prec + " decimal place"
    else 
      str = "Enter a number with at least " + prec + " decimal places"

    if no_min && no_max
      str = str
    else if no_min
      str = str + " that is less than #{@get('constraints.maxValue')}"
    else if no_max
      str = str + " that is greater than #{@get('constraints.minValue')}"
    else
      str = str + " that is between #{@get('constraints.minValue')} and #{@get('constraints.maxValue')}"

    return str

  ).property "constraints.minValue", "constraints.maxValue", "constraints.precision"