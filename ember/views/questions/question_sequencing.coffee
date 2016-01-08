#dropdown for question ordering in question-editor question builder modal
LabCompass.QuestionSequencing = Ember.View.extend
  templateName: "questions/sequence"

  question: null
  otherQuestions: null

  # sequence numbers begin at 1
  sequenceNumber: Ember.computed.alias "question.sequenceNumber"

  didInsertElement: ->
    Ember.run.next(=>
      if isNaN(@get("question.sequenceNumber"))
        @set("question.sequenceNumber", @get("otherQuestions.length") + 1)
    )

  sequenceOptions: ( ->
    otherQuestions = @get "otherQuestions"
    dependencies = @get("question.conditions").mapBy "dependsOn"
    lowestAllowableSequenceNumber = dependencies.reduce (v, questionID) ->
      question = otherQuestions.findBy "id", questionID
      sequenceNumber = if question
        question.get("sequenceNumber") + 1
      else
        1
      Math.max v, sequenceNumber
    , 1

    highestAllowableSequenceNumber = @get "highestAllowableSequenceNumber"

    options = otherQuestions.map (otherQuestion, idx) ->
      nextSequenceNumber = otherQuestion.get("sequenceNumber") + 1
      nextSequenceNumber = idx + 2
      label: "After #{otherQuestion.get("displayName")}"
      value: nextSequenceNumber
      disabled: (nextSequenceNumber < lowestAllowableSequenceNumber) ||
                (nextSequenceNumber > highestAllowableSequenceNumber)

    options.insertAt 0,
      label: "As the first item"
      value: 1
      disabled: lowestAllowableSequenceNumber > 1
  ).property "otherQuestions.[]", "question.conditions.@each.dependsOn", "highestAllowableSequenceNumber"

  dependenciesOnThisQuestion: ( ->
    @get("otherQuestions").reduce (dependencies, question) ->
      dependencies.addObjects question.get("conditions").map (condition) ->
        Dependency.create
          question: question
          condition: condition
    , []
  ).property "otherQuestions.@each.conditions"

  questionsDependingOnThisQuestion: ( ->
    @get("dependenciesOnThisQuestion").filterBy("dependsOn", @get("question.id")).mapBy "question"
  ).property "dependenciesOnThisQuestion.@each.dependsOn", "dependenciesOnThisQuestion.@each.question"

  highestAllowableSequenceNumber: (->
    otherQuestions = @get "otherQuestions"
    @get("questionsDependingOnThisQuestion").reduce (sequenceNumber, question) ->
      retVal = Math.min sequenceNumber, otherQuestions.indexOf(question) + 1
      return retVal
    , @get("otherQuestions.length") + 2
  ).property "questionsDependingOnThisQuestion", "otherQuestions.length"

Dependency = Ember.Object.extend
  question: null
  condition: null

  dependsOn: Ember.computed.alias "condition.dependsOn"
