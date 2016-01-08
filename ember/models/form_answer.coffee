LabCompass.FormAnswer = LD.Model.extend
  id: null

  question: LD.hasOne "formQuestion"
  answer: LD.attr "string"

  # TODO: are these 2 the same thing?
  error: LD.attr "string"
  errorMessage: LD.attr "string"

  filtered: LD.attr "boolean", default: false

  conditionallyDisabled: false

  tempOtherVal: ""

  formattedAnswer: (->
    type = @get("question.type")
    formatter = @container.lookup "formatter:#{type}"
    formatter.format(this)
  ).property("answer", "question.type")


  answerChanged: Ember.observer(->
    @set('error', '')
  , 'answer')

  clearAnswerIfDisabled: ->
    if @get "conditionallyDisabled"
      @set "answer", "\u200d"
    else 
      @set "answer", (@get('answer').replace("\u200d", ''))

