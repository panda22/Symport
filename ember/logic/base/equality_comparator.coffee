LabCompass.EqualityComparator = Ember.Object.extend

  supportedOperators: [
      display: "="
      operator: "="
    ,
      display: "≠"
      operator: "<>"
  ]

  compute: (operator, lefthand, righthand) ->
    switch operator
      when "="
        lefthand == righthand
      when "<>"
        lefthand != righthand
