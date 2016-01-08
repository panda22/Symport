LabCompass.FormQuestion = LD.Model.extend
  id: null

  sequenceNumber: LD.attr "number"
  questionNumber: LD.attr "number"
  personallyIdentifiable: LD.attr "boolean", required: true, default: false
  type: LD.attr "string", required: true, default: "text"
  prompt: LD.attr "string", default: ""
  description: LD.attr "string", default: ""
  variableName: LD.attr "string", default: ""
  displayNumber: LD.attr "string", default: ""

  conditions: LD.hasMany "questionCondition"
  exceptions: LD.hasMany "questionException"

  hasDependency: (->
    @get("conditions.length") > 0
  ).property("conditions.[]")
  isDependency: false

  isTheFirstQuestion: ( ->
    @get('questionNumber') == 1
  ).property "questionNumber"

  displayName: ( ->
    switch @get('type')
      when 'header'
        "Header: #{@get('prompt')}"
      when 'pagebreak'
        "Page Break"
      else
        "#{@get('questionNumber')}: #{@get('prompt')}"
  ).property "prompt", "questionNumber", "type"

  config: LD.hasPolymorphic ->
    switch @get "type"
      when "numericalrange"
        "rangeOptions"
      when "text"
        "textOptions"
      when "checkbox", "radio", "dropdown"
        "selectionOptions"
      when "yesno"
        "booleanOptions"
      else
        null
  , "type"

  isFormattingType: (->
    type = @get("type")
    LabCompass.QuestionTypes.isFormattingType(type)
  ).property("type")

  isAnswerable: Ember.computed.not "isFormattingType"
  includeInGrid: Ember.computed.alias "isAnswerable"
  canBranch: Ember.computed.alias "isAnswerable"

  applyErrors: (errorData) ->
    if errorData
      errors = @get "errors"

      @beginPropertyChanges()
      @_super(errorData)
      errors.add "optionConfigs", errorData["optionConfigs"]
      errors.add "numericConfigMax", errorData["numericalRangeConfigMax"]
      errors.add "numericConfigMin", errorData["numericalRangeConfigMin"]
      errors.add "exceptions", errorData["exception"]

      @endPropertyChanges()
