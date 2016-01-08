LabCompass.QuestionCondition = LD.Model.extend

  dependsOn: LD.attr "string"
  operator: LD.attr "string", default: "="
  value: LD.attr "string"