LabCompass.DependentQuestionIdentifier = (questions) ->
  questions.forEach (question) =>
    (question.get('conditions') || []).forEach (condition) =>
      dependentQuestionID = condition.get "dependsOn"
      dependentQuestion = questions.findBy("id", dependentQuestionID)
      unless Ember.isEmpty dependentQuestion
      	dependentQuestion.set("isDependency", true)

