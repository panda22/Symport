LabCompass.BooleanOptions = LD.Model.extend

  selections: LD.hasMany "questionOption"

  awaken: ->
    selections = @get "selections"
    if Ember.isEmpty(selections)
      @set "selections", [
          value: "Yes",
          code: "1"
        ,
          value: "No",
          code: "2"
      ]