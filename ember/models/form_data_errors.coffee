LabCompass.FormDataErrors = LD.Model.extend
  errorsByQuestion: {}
  errorsByResponse: {}
  numActiveErrors: 0
  numIgnoredErrors: 0
  hasNoErrors: true
  hasNoIgnoredErrors: true

  setHasNoErrors: (->
    @set("hasNoErrors", (@get("numActiveErrors") == 0) )
  ).observes("numActiveErrors")

  setHasNoIgnoredErrors: (->
    @set("hasNoIgnoredErrors", (@get("numIgnoredErrors") == 0) )
  ).observes("numIgnoredErrors")

  clone: ->
    newModel = @storage.createModel("formDataErrors")
    newQuestionErrors = JSON.parse(JSON.stringify(@get("errorsByQuestion")))
    newModel.setup(newQuestionErrors, @get("numActiveErrors"))
    newModel

  #  removeCanceledQuestions: ->
  #    for questionID, errorArray of @get("errorsByQuestion")
  #      allCanceled = true
  #      for errorObj in errorArray
  #        if errorObj.responseID == "8aa1f79e-2be3-4c30-9c38-42d30183bd10" and errorObj.questionID == "7cf75434-03d5-4133-b13d-617d1b659f90"
  #          console.log "no"
  #        unless errorObj.canceled
  #          allCanceled = false
  #          break
  #      if allCanceled
  #        delete @get("errorsByQuestion")[questionID]


  setup: (errorObjs, numErrors) ->
    @set("errorsByQuestion", errorObjs)
    #@set("numActiveErrors", numErrors)
    @updateNumErrors()
    @constructErrorsByResponse()

  constructErrorsByResponse: ->
    result = {}
    for questionID, errorArray of @get("errorsByQuestion")
      for errorObj in errorArray
        unless "canceled" of errorObj
          errorObj["canceled"] = false
        unless errorObj.responseID of result
          result[errorObj.responseID] = []
        result[errorObj.responseID].push(errorObj)
    @set("errorsByResponse", result)

  numActiveErrorsForQuestion: (questionID) ->
    errors = @get("errorsByQuestion")[questionID]
    if Ember.isEmpty(errors)
      return 0
    errorCount = 0
    for errorObj in errors
      if errorObj.isActive and !(errorObj.canceled)
        errorCount += 1
    errorCount

  setQuestionErrors: (questionID, newErrors) ->
    curErrors = @get("errorsByQuestion")
    unless questionID of curErrors
      curErrors[questionID] = []
    tempArr = curErrors[questionID]
    for errorObj in tempArr
      errorObj.canceled = true
    tempArr = tempArr.concat(newErrors)
    #tempArr = newErrors
    curErrors[questionID] = tempArr
    responseErrors = @get("errorsByResponse")
    for errorObj in newErrors
      responseID = errorObj.responseID
      unless responseID of responseErrors
        responseErrors[responseID] = []
      responseErrors[responseID].push(errorObj)
    @updateNumErrors()

  updateNumErrors: ->
    errorCount = 0
    for questionID, errors of @get("errorsByQuestion")
      errorCount += @numActiveErrorsForQuestion(questionID)
    @set("numActiveErrors", errorCount)
