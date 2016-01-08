LabCompass.FormDataActionHandler = Ember.Object.extend
  undoStack: []
  leftGrid: null
  rightGrid: null
  parentController: null
  questionHandler: null
  sortFuncs: null

  init: ->
    @set("questionHandler", new LabCompass.FormDataQuestionChangeHandler())
    @set("questionHandler.parent", @)
    @set("sortFuncs", new LabCompass.FormDataSortFuncs())

  actionObj: (actionName, paramArray, actionModel) ->
    this.actionName = actionName
    this.paramArray = paramArray
    this.actionModel = actionModel

  doAction: (actionName, paramArray) ->
    obj = new @actionObj(actionName, paramArray, @get("parentController.activeModel"))
    @get("undoStack").push(obj)
    @actionList[actionName].action(@, paramArray)

  undoAction: ->
    actionObj = @get("undoStack").pop()
    @actionList[actionObj.actionName].undoAction(@, actionObj.paramArray, actionObj.actionModel)


  actionList:
    goToForm:
      action: (context, paramArray) ->
        context.goToForm(paramArray[0])
      undoAction: (context, paramArray, prevModel) ->
    sort:
      action: (context, paramArray) ->
        context.doSort(paramArray[0], paramArray[1])
    filter:
      action: (context, paramArray) ->
        context.doFilter(paramArray[0], paramArray[1])
    changeQuestion:
      action: (context, paramArray) ->
        context.changeQuestion(paramArray[0], paramArray[1])
    editSecondaryId:
      action: (context, paramArray) ->
        context.editSecondaryId(paramArray[0])


  goToForm: (formData) ->
    activeModel = @get("parentController.activeModel")
    if activeModel != null and formData.get("formID") == activeModel.get("formID")
      return
    unless activeModel == null
      activeModel.removeExcessRows()
    @set("parentController.activeModel", formData)
    @get("parentController").updateRowCount()
    @get("parentController").resetGrid()
    @setTabsToForm(@get("parentController.model").indexOf(formData))


  setTabsToForm: (formIndex) ->
    tabHandler = @get("parentController.tabHandler")
    curIndex = tabHandler.get("firstShownTabIndex")
    numTabs = tabHandler.get("numTabs")
    if formIndex < curIndex
      tabHandler.set("firstShownTabIndex", formIndex)
    else if formIndex > curIndex + numTabs
      tabHandler.set("firstShownTabIndex", formIndex - numTabs + 2)


  doSort: (typeStr, varName) ->
    unless @get("parentController.isModelChange")
      activeModel = @get("parentController.activeModel")
      @set("parentController.isModelChange", true)
      sortTypeStr = @getSortTypeStr(typeStr)
      activeModel.setProperties({
        sortType: @get("sortFuncs.#{typeStr}"),
        sortVariable: varName,
        sortTypeStr: sortTypeStr
      })
      @get("parentController").setProperties({
        curSortType: sortTypeStr,
        curSortVariable: varName
      })
      @get("parentController").requestNewRender()
      @get("parentController.slickHandler.leftGrid").scrollRowIntoView(0)
      Ember.run.next(=>
        @set("parentController.isModelChange", false)
      )

  doFilter: (str, varName) ->
    unless varName == "" or @get("parentController.isModelChange")
      @set("parentController.activeModel.filterVariable", varName)
      @set("parentController.activeModel.filterString", str)
      @get("parentController").requestNewRender()

  changeQuestion: (question, formatObject) ->
    formatFunction = null
    unless Ember.isEmpty(formatObject)
      formatFunction = formatObject.formatFunction
    controller = @get("parentController")
    questions = @get("parentController.activeModel.formStructure.questions")
    originalQuestion = questions.findBy("id", question.id)
    needsRender = @get("questionHandler").handleQuestionChanges(originalQuestion, question)
    if needsRender
      @get("parentController").requestNewRender(true)
    controller.get("storage").updateQuestionFromGrid(question)
    .then (result) =>
      controller.send("closeDialog")
      if formatFunction == null
        controller.get("storage").validateQuestionFromGrid(question.id)
        .then (result) =>
          controller.send("loadingOff")
          controller.get("activeModel.answerErrors").setQuestionErrors(question.id, result.errors)
          controller.setGridErrorFormatting()
        #controller.get("activeModel.answerErrors").updateNumErrors()
      else
        @reformatAnswers(question, formatFunction)
      index = questions.indexOf(originalQuestion)
      questions.replace(index, 1, [question])
    , (error) =>
      controller.send("loadingOff")


  reformatAnswers: (question, formatFunction) ->
    model = @get("parentController.activeModel")
    dataDriver = model.get("dataDriver")
    data = dataDriver.get("data")
    varName = question.get("variableName")
    controller = @get("parentController")
    answerObjects = []
    answerHash = {}
    for row in data
      newAnswer = ""
      responseID = ""
      for cell in row
        if "responseID" of cell
          responseID = cell.responseID
        else if cell.variableName == varName
          newAnswer = formatFunction(cell.value).data
          if newAnswer != cell.value
            answerObjects.push({
              answer: newAnswer,
              responseID: row[0].responseID,
              ignored: false
            })
      if newAnswer != ""
        answerObj = {
          answer: newAnswer.split("\u200c").join(" ● "),
          otherVariableName: "",
          otherAnswer: ""
        }
        answerHash[responseID] = newAnswer.split("\u200c").join(" ● ")

    controller.send("closeDialog")
    controller.send("loadingOff")
    if answerObjects.length > 0
      model.updateAnswersForQuestion(answerHash, varName)
      controller.requestNewRender()
      controller.get("storage").saveAnswersFromGrid(answerObjects, question.id)
      .then (result) =>
        model.get("answerErrors.errorsByQuestion")[question.id] = result.errors
        controller.get("storage").validateQuestionFromGrid(question.id)
        .then (result) =>
          controller.send("loadingOff")
          controller.get("activeModel.answerErrors").setQuestionErrors(question.id, result.errors)
          controller.setGridErrorFormatting()
        , (error) =>
          controller.send("loadingOff")
    else
      controller.get("storage").validateQuestionFromGrid(question.id)
      .then (result) =>
        controller.send("loadingOff")
        controller.get("activeModel.answerErrors").setQuestionErrors(question.id, result.errors)
        controller.setGridErrorFormatting()
      , (error) =>
        controller.send("loadingOff")



  getSortTypeStr: (sortType) ->
    for menuItem in @get("parentController.sortMenuItems")
      if menuItem.class == sortType
        return menuItem.title
    return "asc-unfilled-first" # default

  editSecondaryId: (form) ->
    form.set("fromFormData", true)
    form.set("manyToOneLock", false)
    form.set("manyToOneWarning", false)
    controller = @get("parentController")
    if form.get("isManyToOne")
      controller.storage.getMaxInstancesInFormStructure(form.id)
      .then (numInstances) =>
        if numInstances > 1
          form.set("manyToOneLock", true)
        else if numInstances == 1
          form.set("manyToOneWarning", true)
        controller.send "openDialog", "secondary_id_details", form, "secondaryIdDetails"
    else
      controller.send "openDialog", "secondary_id_details", form, "secondaryIdDetails"

