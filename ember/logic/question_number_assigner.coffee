LabCompass.QuestionNumberAssigner = (sortedQuestions) ->
  qNumber = 0
  sortedQuestions.forEach (question) =>
    type = question.get("type")
    if !LabCompass.QuestionTypes.isFormattingType(type)
      qNumber = qNumber + 1
      question.set("questionNumber", qNumber)
