LabCompass.CheckboxesFormatter = Ember.Object.extend
  format: (answer) ->
    answer.get('answer').replace(/\u200C/g," | ")