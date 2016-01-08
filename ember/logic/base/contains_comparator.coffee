LabCompass.ContainsComparator = Ember.Object.extend

  supportedOperators: [
      display: "contains"
      operator: "="
    ,
      display: "does not contain"
      operator: "<>"
  ]

  compute: (operator, lefthandValues, righthand) ->
    switch operator
      when "="
        lefthandValues.contains righthand
      when "<>"
        !lefthandValues.contains righthand
