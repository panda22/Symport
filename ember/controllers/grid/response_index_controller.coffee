LabCompass.ResponseViewController = Ember.ObjectController.extend LabCompass.ResponseLogicMixin, LabCompass.WithProject,

  needs: ["response", "project", 'responses', 'form', 'application']
  content: Ember.computed.alias "controllers.response.model"
  canEnterData: Ember.computed.alias "controllers.form.model.userPermissions.enterData"

  subjectID: Ember.computed.alias "controllers.responses.subjectID"
  project: Ember.computed.alias "controllers.project.model"
  onMobile: Ember.computed.alias "controllers.application.onMobile"

  canRenameSubjectIDs: Ember.computed.alias "project.userPermissions.renameSubjectIDs"

  isManyToOne: Ember.computed.alias "model.formStructure.isManyToOne"

  hasQuestions: false

  setHasQuestions: (->
    value = (@get("displayedAnswers.length") > 0) and @get("isManyToOne")
    @set("hasQuestions", value)
  ).observes "displayedAnswers.length"

  canCreateInstance: Ember.computed.alias "model.formStructure.userPermissions.enterData"
#  MIXED IN
#  logicCoordinator: null
#  setupLogicCoordinator: (->
#    coordinator = @container.lookup "logic:response"
#    coordinator.set "formResponse", @get "model"
#    @set "logicCoordinator", coordinator
#  ).observes("model").on "init"

  handleTransition: ->
    return true

  hasChanges: ->
    false

  #  instanceNames: Ember.A([])
  #  listenForInstanceNames: (->
  #    if @get("model") == null
  #      return
  #    @set("instanceNames", Ember.A([]))
  #    unless @get("model.isDisplayed")
  #      @set("newInstanceName", "")
  #    searchString = @get("newInstanceName") || ""
  #    for instance in @get("model.allInstances")
  #      #if searchString == "" or instance.secondaryId.indexOf(searchString) != -1
  #      @get("instanceNames").pushObject(instance.secondaryId)
  #  ).observes("model.subjectID", "model.allInstances", "model", "model.allInstances.length")

  #  listenForSecondaryIdChange: ( ->
  #    curVal = @get("model.selectedSecondaryId")
  #    if @get("model") == null or curVal == null or curVal == ""
  #      return
  #    if curVal != @get("model.secondaryId")
  #      found = false
  #      for instance in @get("model.allInstances")
  #        if instance.secondaryId == curVal
  #          if @get('model.formStructure.userPermissions.enterData')
  #            route = "response.edit"
  #          else
  #            route = "instance.view"
  #          found = true
  #          subjectID = @get("model.subjectID")
  #          @transitionToRoute route, instance.instanceNumber
  #          @set("controllers.responses.isInstanceSelected", @hasQuestions)
  #      if found == false
  #        newModel = @getNewInstance()
  #        instanceNumber = newModel.get("allInstances.length")
  #        #if @get("model.id") == null and @get("model.instanceNumber") == instanceNumber and instanceNumber != 0
  #        newModel.set("secondaryId", curVal)
  #        newModel.set("instanceNumber", instanceNumber)
  #        if @get("model.id") == null
  #          @set("model.secondaryId", curVal)
  #        @set("controllers.responses.isInstanceSelected", @hasQuestions)
  #        @set("model.isDisplayed", true)
  #
  #        #else
  #        params = {
  #          queryParams:
  #            isNew: true
  #            newModel: newModel
  #        }
  #        @transitionToRoute("instance.edit", newModel.get("subjectID"), instanceNumber, params)
  #        @set("model.isDisplayed", @hasQuestions)
  #        @set("controllers.responses.isInstanceSelected", @hasQuestions)
  #    else
  #      @set("controllers.responses.isInstanceSelected", @hasQuestions)
  #  ).observes("model.selectedSecondaryId")

  #  newInstanceName: ""
  #
  #  setupNewInstanceName: ( ->
  #    @set("newInstanceName", @get("model.secondaryId"))
  #  ).observes("model.secondaryId")

  otherForms: (->
    @get('project.structures').filter (form) =>
      if form.get('name') != @get('model.formStructure.name')
        form
  ).property "model"

  jumpToForm: null

  jumpToFormObserver: (->
    if !Ember.isEmpty(@get('jumpToForm'))
      nextForm = @get('jumpToForm')
      parent = @get("controllers.responses")
      parent.set("saveSubjectID", true)
      subjectID = @get("controllers.responses.subjectID")
      formID = nextForm.get("id")
      @transitionToRoute("responses", formID)
  ).observes('jumpToForm')


##
# start pagination
##

  QUESTIONS_PER_PAGE: 25

  isPaging: false

  setIsPaging: (->
    if @get("model.sortedAnswers.length") > @QUESTIONS_PER_PAGE
      @set("isPaging", true)
    else
      @set("isPaging", false)
  ).observes("model.sortedAnswers.length")

  curPage: 0


  displayedAnswers: Ember.A([])

  paginatedAnswers: Ember.ArrayProxy.create({content: Ember.A([])})

  paginationInfo: {
    lastQuestionName: "",
    pages: Ember.A([]),
    firstPage: null,
    lastPage: null
  }

  curPageInfo: Ember.Object.create({
    firstQuestionName: "",
    lastQuestionName: "",
    index: 0,
    questionIndex: 0,
    isCurPage: true
  })


  setupDisplayedQuestions: (curPage=0) ->
    if @get("model.sortedAnswers.length") == 0
      @set("displayedAnswers", Ember.A([]))
      return
    @set("curSearchString", "")
    @set("curPage", curPage)
    start = curPage * @QUESTIONS_PER_PAGE
    @set("paginatedAnswers", Ember.A([]))
    if @get("model.sortedAnswers") != null
      @get("paginatedAnswers").pushObjects(@get("model.sortedAnswers").slice(start, start + @QUESTIONS_PER_PAGE))
    @set("displayedAnswers", @get("paginatedAnswers"))
    @setupPaginationInfo()

  setupPaginationInfo: ->
    if @get("model.sortedAnswers") == null
      return
    allAnswers = @get("model.sortedAnswers")
    numQuestions = allAnswers.length
    lastQuestion = allAnswers[numQuestions - 1].get("question.sequenceNumber")
    pages = Ember.A([])
    questionIndex = 0
    index = 0
    firstPage = null
    lastPage = null
    while questionIndex < numQuestions
      pageObj = Ember.Object.create({})
      pageObj.set("index", index)
      pageObj.set("questionIndex", questionIndex)
      pageObj.set("isCurPage", if (index == @curPage) then true else false)
      pageObj.set("firstQuestionName", allAnswers[questionIndex].get("question.sequenceNumber"))
      lastIndex = Math.min(numQuestions - 1, questionIndex + @QUESTIONS_PER_PAGE - 1)
      pageObj.set("lastQuestionName", allAnswers[lastIndex].get("question.sequenceNumber"))
      pages.pushObject(pageObj)
      if firstPage == null
        firstPage = pageObj
      if pageObj.isCurPage == true
        @set("curPageInfo", pageObj)
      questionIndex += if (@QUESTIONS_PER_PAGE > 0) then @QUESTIONS_PER_PAGE else 1
      if questionIndex >= numQuestions
        lastPage = pageObj
      index += 1
    returnObj = {
      lastQuestionName: lastQuestion,
      pages: pages,
      firstPage: firstPage,
      lastPage: lastPage
    }
    @set("paginationInfo", returnObj)

  listenForChangeInDisplayedQuestions: (->
    if @get("model.sortedAnswers") == null or @get("model.sortedAnswers.length") == 0
      @set("displayedAnswers", Ember.A([]))
    @setupDisplayedQuestions()
  ).observes("model.sortedAnswers")

  findPageByQuestion: (question) ->
    seqNum = question.get("sequenceNumber")
    return Math.floor((seqNum - 1) / @QUESTIONS_PER_PAGE)

  questionSearchArray: Ember.computed(->
    @setupQuestionSearchArray()
  )

  setupQuestionSearchArray: (->
    if @get("model.sortedAnswers") == null or @get("model.sortedAnswers.length") == 0
      @set("questionSearchArray", Ember.A([]))
      return
    arr = Ember.A([])
    for answer in @get("model.sortedAnswers")
      question = answer.get("question")
      displayName = question.get("displayName")
      varName = question.get("variableName")
      if varName == ""
        arr.push("\u200b#{displayName}\u200b")
      else
        arr.push("#{displayName} \u200a[#{varName}]\u200a")
    @set("questionSearchArray", arr)
    arr
  ).observes("model.sortedAnswers")

  curSearchString: ""

  searchForQuestion: (->
    if @get("curSearchString") == null or @get("curSearchString") == ""
      return
    varName = ""
    isVarNameSearch = true
    if (@get("curSearchString").indexOf("\u200a") != -1)
      varName = @get("curSearchString").split("\u200a")[1].slice(1, -1)
    else if (@get("curSearchString").indexOf("\u200b") != -1) # search for display name (header type)
      isVarNameSearch = false
      varName = @get("curSearchString").split("\u200b")[1]
    if varName != ""
      target = null
      for answer in @get("model.sortedAnswers")
        question = answer.get("question")
        if isVarNameSearch and question.get("variableName") == varName
          target = question
          break
        if !isVarNameSearch and question.get("displayName") == varName
          target = question
          break
      if target != null
        newPage = @findPageByQuestion(target)
        if newPage != @get("curPage")
          @setupDisplayedQuestions(newPage)
          Ember.run.next(=>
            Ember.run.later(=>
              @setupQuestionSearch(target)
            , 500)
          )
        else
          @set("curSearchString", "")
          @setupQuestionSearch(target)
  ).observes("curSearchString")

  setupQuestionSearch: (question) ->
      Ember.run.next(->
        answerBoxDiv = $("#" + question.get('id')).find(".form-answer-box")
        if answerBoxDiv.length == 0
          answerBoxDiv = $("#" + question.get('id')).find(".header")
        answerBoxDiv.addClass("with-gray-shadow")
        curPos =  $('body').scrollTop()
        newPos = answerBoxDiv.offset().top
        bottomMargin = parseInt($(window).height()) - answerBoxDiv.height()
        target = answerBoxDiv.offset().top - (parseInt($(window).height()) / 2)
        shouldMove = ((curPos + bottomMargin - newPos) < 0 or (newPos - curPos) < 0)
        if shouldMove
          $('html, body').scrollTop(target)
          window.setTimeout(->
            answerBoxDiv.removeClass("with-gray-shadow")
          , 1000)
      )

##
# end pagination
##

  actions:
    changePage: (pageInfo) ->
      @setupDisplayedQuestions(pageInfo.get("index"))
      Ember.run.next(->
        $("body").scrollTop(0)
      )

    selectSecondaryId: ->
      @set("model.selectedSecondaryId", @get("newInstanceName"))

    edit: ->
      @transitionToRoute "instance.edit", @get("model.instanceNumber")
