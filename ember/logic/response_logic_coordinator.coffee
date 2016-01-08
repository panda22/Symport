LabCompass.ResponseLogicCoordinator = Ember.Object.extend

  formResponse: null
  answers: Ember.computed.alias "formResponse.answers"

  dependencies: []
  generateDependencies: (->

    newDependencies = @get("answers").map((answer) =>
      conditions = answer.get("question.conditions")
      conditions.map (condition) =>
        dependentQuestionID = condition.get "dependsOn"
        dependsOnAnswer = @get("answers").findBy "question.id", dependentQuestionID
        dependency = @container.lookupFactory("logic:responseDependency").create()
        dependency = dependency.setProperties
          dependsOnAnswer: dependsOnAnswer
          affectedAnswer: answer
          operator: condition.get "operator"
          value: condition.get "value"

        dependency.on "dependencyChangedFor", (questionID) =>
          @updateStatusFor questionID
        dependency
    ).reduce (acc, elem) ->
      acc.concat(elem)
    , []

    @set "dependencies", newDependencies
    @updateAllStatuses()
  ).observes "formResponse.answers.[]"

  updateStatusFor: (questionID) ->
    #find related dependencies
    dependencies = @get("dependencies").filterBy "affectedAnswer.question.id", questionID
    #check them all
    satisfied = dependencies.reduce (satisfied, dependency) ->
      satisfied && dependency.get("satisfied")
    , true
    #set whether enabled
    @get("answers").findBy("question.id", questionID).set("conditionallyDisabled", !satisfied)

  updateAllStatuses: ->
    questionsWithDependencies = Ember.Set.create()
    @get("dependencies").forEach (dependency) ->
      questionsWithDependencies.push dependency.get("affectedAnswer.question.id")
    questionsWithDependencies.forEach (questionID) =>
      @updateStatusFor questionID


LabCompass.ResponseDependency = Ember.Object.extend Ember.Evented,
  dependsOnAnswer: null
  affectedAnswer: null
  operator: null
  value: null

  depndentAnswerChanged: (->
    @trigger "dependencyChangedFor", @get("affectedAnswer.question.id")
  ).observes("dependsOnAnswer.answer", "dependsOnAnswer.conditionallyDisabled").on "init"

  satisfied: (->
    if @get "dependsOnAnswer.conditionallyDisabled"
      false
    else
      questionType = @get "dependsOnAnswer.question.type"
      comparator = @container.lookup("comparator:#{questionType}")
      comparator.compute @get("operator"), @get("dependsOnAnswer.answer"), @get("value")
  ).property "dependsOnAnswer.answer", "dependsOnAnswer.question.type",
    "dependsOnAnswer.conditionallyDisabled", "operator", "value"

LabCompass.register "logic:response", LabCompass.ResponseLogicCoordinator, singleton: false
LabCompass.register "logic:responseDependency", LabCompass.ResponseDependency, singleton: false
