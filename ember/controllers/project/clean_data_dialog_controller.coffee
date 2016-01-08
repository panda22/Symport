LabCompass.CleanDataDialogController = Ember.Controller.extend
  isManyToOne: Ember.computed.alias("model.formStructure.isManyToOne")


  findValue: ""
  replaceValue: ""

  showSaved: false
  fixedErrorCount: 0

  editErrors: {}

  setEditErrors: (->
    errorsCopy = @get("model.answerErrors").clone()
    @set("editErrors", errorsCopy)
  ).observes("model", "model.curErrorQuestionID")

  curErrorQuestionID: ""

  setCurErrorQuestionID: (->
    id = ""
    if Ember.isEmpty(@get("model.curErrorQuestionID"))
      id = Object.keys(@get("editErrors.errorsByQuestion"))[0]
    else
      id = @get("model.curErrorQuestionID")
    @set("curErrorQuestionID", id)
  ).observes("model", "model.curErrorResponseID")

  curQuestion: null

  setCurQuestion: ->
    if Ember.isEmpty(@get("curErrorQuestionID"))
      return
    question = @get("model.formStructure.questions").findBy("id", @get("curErrorQuestionID"))
    @set("curQuestion", question)

  isDateType: false
  isCheckboxType: false
  hasOtherVariable: false
  otherVariableName: ""

  setIsDateType: ->
    question = @get("curQuestion")
    if Ember.isEmpty(question)
      return
    if question.get("type") == "date"
      @set("isDateType", true)
    else
      @set("isDateType", false)

  setIsCheckboxType: ->
    question = @get("curQuestion")
    if Ember.isEmpty(question)
      return
    if question.get("type") == "checkbox"
      @set("isCheckboxType", true)
    else
      @set("isCheckboxType", false)

  setHasOtherVariable: ->
    question = @get("curQuestion")
    if Ember.isEmpty(question)
      return
    setVal = false
    otherVarName = ""
    if question.get("config.selections.content.length")
      for option in question.get("config.selections.content")
        if option.get("otherOption")
          otherVarName = option.get("otherVariableName")
          setVal = true
          break
    @set("hasOtherVariable", setVal)
    @set("otherVariableName", otherVarName)


  monthExceptions: Ember.A([])
  dayExceptions: Ember.A([])
  yearExceptions: Ember.A([])
  
  setDateExceptions: (->
    @setProperties({
      monthExceptions: Ember.A([]),
      dayExceptions: Ember.A([]),
      yearExceptions: Ember.A([])
    })
    if @get("isDateType")
      for exception in @get("curQuestion.exceptions.content")
        switch exception.get("exceptionType")
          when "date_month"
            @get("monthExceptions").pushObject(exception)
          when "date_day"
            @get("dayExceptions").pushObject(exception)
          when "date_year"
            @get("yearExceptions").pushObject(exception)
  ).observes("isDateType")

  curErrorResponseID: ""

  ignoreAllSet: false

  init: ->
    context = @
    $(document).on("click", ".form-data-cleanup-bg", ->
      context.confirmCloseDialog()
    )

  numQuestions: 0

  setNumQuestions: (->
    num = Object.keys(@get("editErrors.errorsByQuestion")).length
    @set("numQuestions", num)
  ).observes("model", "model.curErrorResponseID")

  moreThanOneQuestion: true

  setMoreThanOneQuestion: (->
    @set("moreThanOneQuestion", @get("numQuestions") > 1)
  ).observes("numQuestions")

  curErrorList: []

  setCurErrorList: (->
    @setCurQuestion()
    @setIsDateType()
    @setIsCheckboxType()
    @setHasOtherVariable()
    result = []
    id = @get("curErrorQuestionID")
    unless Ember.isEmpty(@get("editErrors.errorsByQuestion")[id])
      for errorObj in @get("editErrors.errorsByQuestion")[id]
        unless errorObj.canceled
          if @get("isCheckboxType")
            Ember.set(errorObj, "answer", errorObj.answer.split("\u200c").join("\n"))
          result.push(errorObj)
      @sortErrors(result)
    @set("curErrorList", result)
  ).observes("curErrorQuestionID", "editErrors")

  getNextQuestionID: (arr, curVal) ->
    found == false
    for questionID in arr
      if found
        return questionID
      if questionID == curVal
        found = true
    return arr[0]

  saveCurrentQuestion: ->
    answerObjs = []
    for errorObj in @get("curErrorList")
      answer = errorObj.answer
      if @get("isCheckboxType")
        answer = answer.split("\n").join("\u200c")
      answerObjs.push({
        responseID: errorObj.responseID,
        answer: answer,
        ignored: !errorObj.isActive,
        otherAnswer: errorObj.otherAnswer
      })
    unless answerObjs.length == 0
      @set("needsReRender", true)
      @storage.saveAnswersFromGrid(answerObjs, @get("curQuestion.id")).then( (result) =>
        if result.success
          @updateAnswers()
          @sortErrors(result.errors)
          @get("editErrors.errorsByQuestion")[@get("curErrorQuestionID")] = result.errors
          @notifyPropertyChange("editErrors")
          if result.errors.length == 0
            @removeQuestionFromErrorList(@get("curErrorQuestionID"))
          else
            @get("model.answerErrors.errorsByQuestion")[@get("curErrorQuestionID")] = result.errors
            @get("model.answerErrors").constructErrorsByResponse()
          @get("model.answerErrors").updateNumErrors()
          @showSaveNotification(result.fixedCount)
      )

  sortErrors: (errors) ->
    errors.sort( (a, b) ->
      if a.subjectID == b.subjectID
        return 0
      else if a.subjectID < b.subjectID
        return -1
      else
        return 1
    )

  updateAnswers: ->
    answerHash = {}
    for errorObj in @get("curErrorList")
      answer = errorObj.answer
      if @get("isCheckboxType")
        answer = errorObj.answer.split("\n").join(" ● ")
      answerObj = {
        answer: answer,
        otherVariableName: @get("otherVariableName"),
        otherAnswer: errorObj.otherAnswer
      }
      answerHash[errorObj.responseID] = answerObj
    varName = @getQuestionVarName(@get("curErrorQuestionID"))
    @get("model").updateAnswersForQuestion(answerHash, varName)

  removeQuestionFromErrorList: (questionID)->
    delete @get("model.answerErrors.errorsByQuestion")[questionID]
    delete @get("editErrors.errorsByQuestion")[questionID]
    @set("curErrorList", [])
    @get("model.answerErrors").constructErrorsByResponse()
    if @get("numQuestions") <= 1
      @send("closeDataCleanDialog", true)
    else
      @send("nextQuestion")
    @setNumQuestions()

  getQuestionVarName: (id) ->
    @get("model.formStructure.questions").findBy("id", id).get("variableName")

  needsReRender: false

  confirmCloseDialog: ->
    changedQuestionID = @getQuestionIDWithChanges()
    if changedQuestionID == null || confirm("There are unsaved changes. Are you sure you want to leave?")
      needsReRender = @get("needsReRender")
      @send("closeDataCleanDialog", needsReRender)
      @set("needsReRender", false)
      @set("curErrorResponseID", "")
    else
      @set("curErrorQuestionID", changedQuestionID)

  # returns null if no question has changes
  getQuestionIDWithChanges: ->
    for questionID, originalErrors of @get("model.answerErrors.errorsByQuestion")
      newErrors = @get("editErrors.errorsByQuestion")[questionID]
      if @hasChanges(originalErrors, newErrors)
        return questionID
    return null

  hasChanges: (originalErrors, newErrors)->
    @sortErrors(originalErrors)
    @sortErrors(newErrors)
    if originalErrors.length != newErrors.length
      return true
    for oldError, i in originalErrors
      newError = newErrors[i]
      if !@isSameError(oldError, newError)
        return true
    return false


  isSameError: (oldError, newError) ->
    if Ember.isEmpty(oldError.answer) and Ember.isEmpty(newError.answer)
      return true
    else if Ember.isEmpty(oldError.answer) or Ember.isEmpty(newError.answer)
      return false
    else if oldError.answer.replace(/\u200c/g, "") != newError.answer.replace(/\n/g, "").replace(/\u200c/g, "")
      return false
    else if oldError.isActive != newError.isActive
      return false
    return true

  resTip1: ""
  resTip2: ""
  set_resolution_tip: (->
    q = @get 'curQuestion'
    s = ""
    if Ember.isEmpty q
      return
    qType = q.get('type')
    config = q.get('config')
    variableName = q.get('variableName')
    #mapping = @get 'model.mapping'
    formatIndex = 0
    @set "resTip2", ""


    switch qType
      when "timeduration"
        @set 'resTip1', "Please enter hour, minute, and second values for the time duration, separated by a colon (:). These must be numeric characters"
      when "date"
        format = LabCompass.DateImportFormats[formatIndex].display
        @set 'resTip1', "Please enter a date in the format MM/DD/YYYY"
      when "zipcode"
        @set 'resTip1', "Please enter a Zipcode, it must be exactly 5 numeric characters."
      when "checkbox"
        format = LabCompass.CheckboxImportFormats[formatIndex].display
        list = config._data.selections.content
        @set 'resTip1', ("Some answers may be incomplete or spelled wrong. Checkbox answers must match the choices listed below and must" +
                        " be separated by a new line (enter)")

        for option in list
          s = s + option._data.value + ", "
        l = s.length
        s = s.slice(0, l-2) + ". "
        @set 'resTip2', s
      when "email"
        @set 'resTip1', "Please enter an email in the format example@xyz.com. The @ and . are required."
      when "radio"
        list = config._data.selections.content
        @set "resTip1", "Some answers may be incomplete or spelled wrong. Radio answers must match the question's answer choices listed below."
        for option in list
          s = s + option._data.value + ", "
        l = s.length
        s = s.slice(0, l-2) + ". "
        @set 'resTip2', s
      when "dropdown"
        list = config._data.selections.content
        @set 'resTip1', ("Some answers may be incomplete or spelled wrong. Dropdown answers must match the question's answer choices listed below.")
        for option in list
          s = s + option._data.value + ", "
        l = s.length
        s = s.slice(0, l-2) + ". "
        @set 'resTip2', s
      when "yesno"
        @set 'resTip1', "Answers must be 'yes' or 'no'. Please be sure they are spelled out completely and correctly."
      when "timeofday"
        format = LabCompass.TimeOfDayImportFormats[formatIndex].display
        @set 'resTip1', ("Please enter a time of day in the " + format + ". Be sure to include the space between the 'am'/'AM' or 'pm'/'PM’.")
      when "phonenumber"
        format = LabCompass.PhoneNumberImportFormats[formatIndex].display
        @set 'resTip1', ("Please enter a phone number in the format " + format + ".")
      when "numericalrange"
        min = config._data.minValue
        max = config._data.maxValue
        prec = config._data.precision
        s = "Numbers cannot contain non numeric characters and must be within the set range. For this question, answers must be a number between  " + min + " and " + max
        if prec == 6
          s = s + " and can have any number of decimal places."
        else if prec == 0
          s = s + " and must be a whole number."
        else if prec == 1
          s = s + " and have the specified precision of 1 decimal place."
        else
          s = s + " and have the specified precision of " + prec + " decimal places."
        @set 'resTip1', s

  ).observes 'curQuestion'

  showSaveNotification: (fixedCount) ->
    if fixedCount > 0
      @storage.set('session.user.clean', true)
      @set("fixedErrorCount", fixedCount)
      savedNotificationDelay = 5000
      @set("showSaved", true)
      Ember.run.later( =>
        @set("showSaved", false)
        @set("fixedErrorCount", 0)
      , savedNotificationDelay)

  actions:
    close: ->
      @confirmCloseDialog()

    save: ->
      @saveCurrentQuestion()

    previousQuestion: ->
      @send("loadingOn")
      ids = Object.keys(@get("editErrors.errorsByQuestion")).reverse()
      curID = @get("curErrorQuestionID")
      newID = @getNextQuestionID(ids, curID)
      @set("curErrorQuestionID", newID)
      Ember.run.next(=>
        @send("loadingOff")
      )

    nextQuestion: ->
      @send("loadingOn")
      ids = Object.keys(@get("editErrors.errorsByQuestion"))

      curID = @get("curErrorQuestionID")
      newID = @getNextQuestionID(ids, curID)
      @set("curErrorQuestionID", newID)
      Ember.run.next(=>
        @send("loadingOff")
      )

    findAndReplace: ->
      @send("loadingOn")
      findBoxValue = @get("findValue")
      if Ember.isEmpty(findBoxValue)
        alert("Please put some text in the find box.")
        @send("loadingOff")
        return
      replaceBoxValue = @get("replaceValue")
      if replaceBoxValue != "" || (replaceBoxValue == "" && confirm("Are you sure you wish to delete all occurences of '" + findBoxValue + "'"))
        for errorObj in @get("curErrorList")
          if errorObj.isActive == false
            continue
          regexp = new RegExp(findBoxValue.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"), "gi")
          #regexp = new RegExp(findBoxValue)
          replaceVal = errorObj.answer.replace(regexp,replaceBoxValue)
          Ember.set(errorObj, "answer", replaceVal)
      @send "loadingOff"

    ignoreAll: ->
      for errorObj, i in @get("curErrorList")
        #@set("curErrorList.#{i}.isActive", false)
        Ember.set(errorObj, "isActive", false)
      @set("ignoreAllSet", true)
      return false

    undoIgnoreAll: ->
      for errorObj, i in @get("curErrorList")
        #@set("curErrorList.#{i}.isActive", true)
        Ember.set(errorObj, "isActive", true)
      @set("ignoreAllSet", false)

    ignoreAnswer: (errorObj) ->
      Ember.set(errorObj, "isActive", false)

    undoIgnore: (errorObj) ->
      Ember.set(errorObj, "isActive", true)
      return false



