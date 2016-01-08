LabCompass.QuestionsConditionController = Ember.ObjectController.extend
  needs: 'questionDialog'
  question: Ember.computed.alias('controllers.questionDialog.model')

  conditionIndex: ( ->
    @get('question.conditions').indexOf(@get('model')) + 1
  ).property 'model', 'question.conditions.[]'

  dependsOnQuestion: null
  whenDependsOnQuestionChanges: (->
    @set "model.dependsOn", @get("dependsOnQuestion.id")
    #try $(".conditionSelector")[0].parentElement.setAttribute("style", "background: #D4f4E4")
  ).observes "dependsOnQuestion.id"

  contentDidChange: ( ->
    questionID =  @get('model.dependsOn')
    if questionID
      question = @get('target.previousAnswerableQuestions').findBy('id', questionID)
      @set('dependsOnQuestion', question)
  ).observes('model').on "init"

  isNotFirst: ( ->
    if @get("controllers.questionDialog.numConditions") > 1
      return true
    else
      return false
  ).property "controllers.questionDialog.numConditions"

  actions:
    removeCondition: ->
      if Ember.isEmpty(@get("question"))
        @send("removeConditionAction", @get("model"))
      else
        @get('question.conditions').removeObject(@get('model'))

  needsSecondaryStyling: (->
    typeofquestion = @get "dependsOnQuestion.type"
    if typeofquestion == "timeofday" || typeofquestion == "timeduration" || typeofquestion == "phonenumber"
      return true
    else
      return false
  ).property "dependsOnQuestion.type"
