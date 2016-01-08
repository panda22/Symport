LabCompass.QuestionEditorNumericalRangeFields = Ember.View.extend
  layoutName: "questions/default_layout"
  templateName: "questions/numericalrange"

  precisionValues: [
    name: 'Any number of decimal places'
    value: 6
  ,
    name: 'Whole numbers only'
    value: 0
  ,
    name: '0.1'
    value: 1
  ,
    name: '0.01'
    value: 2
  ,
    name: '0.001'
    value: 3
  ,
    name: '0.0001'
    value: 4
  ,
    name: '0.00001'
    value: 5
  ]
