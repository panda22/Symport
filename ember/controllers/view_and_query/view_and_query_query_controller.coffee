LabCompass.ViewAndQueryQueryController = Ember.ObjectController.extend LabCompass.WithProject,
  needs: ["project", 'form', 'application']

  breadCrumb: (->
    if @get("id")
      "#{@get('name')} - Edit Query Parameters"
    else
      "Build"
  ).property("id")

  hasParamErrors: false
  showPageErrors: false
  queryObjects: Ember.A([])
  isSelectAll: true
  queryConjunction: "and"
  querySeparator: "AND"
  isMoreThan1Param: false
  displayedForms: Ember.A([])
  forms: Ember.A([])
  secondaryIds: null
  hasBlockedForms: false
  isDomLoading: false
  parentModel: null
  storedTransition: null
  isSaved: false
  allFormsSelected: false
  hasBlockedPhi: false

  uniqSecondaryIds: (->
    temp = {}
    for formId, ids of @get("secondaryIds")
      temp[formId] = []
      for id in ids
        if temp[formId].indexOf(id) == -1
          temp[formId].push(id)
    temp
  ).property("secondaryIds")

  setHasParamErrorsOnLoad: (->
    @set("hasParamErrors", false)
  ).property("model")

  showSelectAll: (->
    #should never have a length of 0 because then the 
    #empty state message will be shown
    if @get("model.queriedForms.length") == 1 
      return false
    else
      return true
  ).property("model.queriedForms")

  errorMessages: (->
    try
      messageObj = JSON.parse(@get("model.changeMessage"))
      result = Ember.A([])
      for type, errorObj of messageObj
        if type == "secondary ID"
          result.push(@constructErrorString(type, errorObj, false))
        else
          result.push(@constructErrorString(type, errorObj, true))
      result
    catch
      Ember.A([])
  ).property("model", "model.changeMessage")

  constructErrorString: (type, errorObj, isDelete) ->
    str = "Query parameters have been removed because #{type}"
    moreThanOne = errorObj.length > 1
    if moreThanOne
      str += "s "
    else
      str += " "
    for formName, i in errorObj
      if i != 0
        str += ", "
      str += formName
    if moreThanOne
      str += " have"
    else
      str += " has"
    if isDelete
      str += " been deleted."
    else
      str += " been changed."
    str += " Please update the parameters."
    str

  setIsSaved: (->
    @set("isSaved", false)
  ).observes("model")

  unsetIsSaved: (->
    if @get("isSaved") == true
      @unsetIsSavedOnClick()
  ).observes("isSaved")

  unsetIsSavedOnClick: ->
    controller = @
    $("body").one("click", ->
      Ember.run.next(->
        if controller.get("model").compare(controller.get("parentModel")) == false
          controller.set("isSaved", false)
        else
          controller.unsetIsSavedOnClick()
      )
    )

  addCheckBoxObservers: (->
    unless Ember.isEmpty(@get("model"))
      for form in @get("model.queriedForms.content")
        form.addObserver("included", @, @observeFormCheckBox)
    if @get("model.queriedForms.length")
      @observeFormCheckBox(@get("model.queriedForms.firstObject"))
  ).observes("model")

  observeFormCheckBox: (formObj) ->
    allIncluded = true
    for form in @get("model.queriedForms.content")
      unless form.get("included")
        allIncluded = false
    @set("allFormsSelected", allIncluded)



  queryConjunctionViews: Ember.A([
    "Show data that meets ALL of the above statements",
    "Show data that meets ANY of the above statements"])

  queryConjunctionViewSelected: ""

  setQueryConjunctionViewSelected: (->
    if @get("model.conjunction") == "or"
      @set("queryConjunctionViewSelected", @get("queryConjunctionViews")[1])
    else
      @set("queryConjunctionViewSelected", @get("queryConjunctionViews")[0])
  ).observes("model.conjunction")

  listenForQueryConjunction: (->
    if @get("queryConjunctionViewSelected") == @get("queryConjunctionViews")[0]
      @set("model.conjunction", "and")
    else
      @set("model.conjunction", "or")
  ).observes("queryConjunctionViewSelected")

  listenForQuerySeparator: (->
    @set("querySeparator", @get("model.conjunction").toUpperCase())
  ).observes("model.conjunction")

  listenForMoreThan1Param: (->
    if @get("model.queryParams.length") > 1
      @set("isMoreThan1Param", true)
    else
      @set("isMoreThan1Param", false)
  ).observes("model.queryParams.length", "model")

  setup: ->
    return

  addQueryParam: ->
    params = @get("model.queryParams")
    newParam = @storage.createModel("queryParam")
    newParam.set("sequenceNum", params.get("length") + 1)
    newParam.set("isLast", true)
    for param in params.content
      param.set("isLast", false)
    params.pushObject(newParam)


  deleteQueryParam: (sequenceNum) ->
    params = @get("model.queryParams")
    if sequenceNum != params.get("length")
      newParams = Ember.A([])
      params.forEach (param, i) =>
        tempNum = param.get("sequenceNum")
        if tempNum > sequenceNum
          param.set("sequenceNum", i)
    params.removeAt(sequenceNum - 1)
    if params.get("length") > 0
      params.get("lastObject").set("isLast", true)


  handleParamErrors: ->
    allErrors = false
    for param, i in @get("model.queryParams")
      inputErrors = []
      if param.get("formName") == ""
        allErrors = true
        inputErrors.push(0)
      if param.get("questionName") == ""
        allErrors = true
        inputErrors.push(1)
      if param.get("operator") == ""
        allErrors = true
        inputErrors.push(2)
      @addInputError(i, inputErrors)
    if @get("hasParamErrors") == false
      @set("hasParamErrors", allErrors)
    return allErrors


  addInputError: (paramIndex, inputIndeces) ->
    parent = $(".param-wrapper:eq(#{paramIndex})")
    if inputIndeces.length == 0
      parent.find(".param-error").addClass("hide")
    else
      parent.find(".param-error").removeClass("hide")
    if inputIndeces.indexOf(3) != -1 # contains value error
      parent.find(".query-answer-selector input").addClass("single-param-error")
    else
      parent.find(".query-answer-selector input").removeClass("single-param-error")
    for i in [0..2]
      if inputIndeces.indexOf(i) > -1
        parent.find(".drop-down-wrapper:eq(#{i})").addClass("single-param-error")
      else
        parent.find(".drop-down-wrapper:eq(#{i})").removeClass("single-param-error")

  handleTransition: (transition) ->
    transition.isAborted = false
    model = @get("model")
    if transition.targetName == "view-and-query.results" and Ember.isEmpty(transition.queryParams.query) == false
      @set("storedTransition", transition)
    else if transition.targetname == "account.revalidate-session"
    else
      unless model.get("id") == null or model.compare(@get("parentModel"))
        @set("storedTransition", transition)
        model.set("otherModel", @get("controller.parentModel"))
        @send "openDialog", "confirm_unsaved_query", model, "viewAndQueryConfirmLeaveSavedQuery"
        transition.abort()

  resizeListenerSecond: (e)->
    if $(window).width() <= 1110
      $(".secondOne .joyride-nub").removeClass("top")
      $(".secondOne .joyride-nub").addClass("bottom")
      top_val = $(".joyride-tip-guide.secondOne").css("top")
      top_val = Number(top_val.substring(0, top_val.length-2))
      top_val = top_val - 255
      $(".joyride-tip-guide.secondOne").css("top", top_val + "px")
      e.preventDefault()
      e.stopPropagation()


  resizeSecond: ->
    if $(window).width() <= 1110
      $(".secondOne .joyride-nub").removeClass("top")
      $(".secondOne .joyride-nub").addClass("bottom")
      top_val = $(".joyride-tip-guide.secondOne").css("top")
      top_val = Number(top_val.substring(0, top_val.length-2))
      top_val = top_val - 255
      $(".joyride-tip-guide.secondOne").css("top", top_val + "px")

  waitForDropdown: ->
    dropdown = $(".drop-down-input.blue-arrow")
    myModel = @get "project"
    if dropdown.length > 1
      $($(".drop-down-input.blue-arrow")[1]).attr("id", "buildQueryInfo2")
      $("#queryBuildingJoyride").foundation('joyride', 'off')
      $("#queryBuildingJoyride").foundation('joyride', 'start')
      $(".joyride-close-tip").remove()
      nextButtons = $(".joyride-next-tip")
      $(nextButtons[1]).css("display", "none")
      $(".joyride-nub").remove()
      $(nextButtons[0]).on 'click', =>
        $("#buildQueryInfo2").addClass("animated pulse infinite")
        myModel.set("demoProgress.buildQueryInfo", true)
        @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
        $("#buildQueryInfo2").parent().on 'click', =>
          $("#buildQueryInfo2").removeClass("animated pulse infinite")
          $(".submit-query").addClass("animated pulse infinite")
        $(".submit-query").on 'click', =>
          $(".submit-query").removeClass("animated pulse infinite")
          $("#buildQueryInfo2").removeClass("animated pulse infinite")
          myModel.set("demoProgress.buildQueryParams", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
    else
      window.setTimeout(=>
        @waitForDropdown()
      , 100)

  waitForDropdown2: ->
    dropdown = $(".drop-down-input.blue-arrow")
    myModel = @get "project"
    if dropdown.length > 1
      $($(".drop-down-input.blue-arrow")[1]).attr("id", "buildQueryInfo2")
      $("#queryBuildingJoyride").foundation('joyride', 'off')
      $("#queryBuildingJoyride").foundation('joyride', 'start')
      $(".joyride-close-tip").remove()
      nextButtons = $(".joyride-next-tip")
      $(nextButtons[0]).trigger('click')
      $(nextButtons[1]).css("display", "none")
      $(".joyride-nub").remove()
      $("#buildQueryInfo2").addClass("animated pulse infinite")
      $("#buildQueryInfo2").parent().on 'click', =>
        $("#buildQueryInfo2").removeClass("animated pulse infinite")
        $(".submit-query").addClass("animated pulse infinite")
      $(".submit-query").on 'click', =>
        $(".submit-query").removeClass("animated pulse infinite")
        $("#buildQueryInfo2").removeClass("animated pulse infinite")
        myModel.set("demoProgress.buildQueryParams", true)
        @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
    else
      window.setTimeout(=>
        @waitForDropdown2()
      , 100)

  handleDemoStuff: ->
    Ember.run.next(=>
      myModel = @get "project"
      if myModel.get("isDemo") == true
        if myModel.get("demoProgress.createNewQuery") == true
          if myModel.get("demoProgress.queryBuilderProgress") == false
            Ember.run.later(=>
              @get("queryParams.content").insertAt(0, @storage.createModel "queryParam", formName: "Demo Form", questionName: "satisfied", questionType: "yesno", operator: '=', value: '', sequenceNum: 1, isLast: true)
              if myModel.get("demoProgress.buildQueryInfo") == false
                @waitForDropdown()
              else
                @waitForDropdown2()
            ,1000)

    )

  positionSaveQueryPopup: ->
    popup = $(".save-query-params")
    if popup.length > 0
      popupWidth = $(".save-query-params").width()
      windowWidth = $(window).width()
      if windowWidth > popupWidth
        diffWidth = windowWidth - popupWidth
        $(".save-query-params").css("left", diffWidth + "px")
        $(window).on 'resize', =>
          @positionSaveQueryPopup()
    else
      window.setTimeout(=>
        @positionSaveQueryPopup()
      , 100)

  selectAll: (add) ->
    for form in @get("model.queriedForms.content")
      form.set("included", add)

  actions:
    selectAllForms: (add) ->
      @selectAll(add)

    toggleConjunction: ->
      if @queryConjunction == "and"
        @set("queryConjunction", "or")
      else
        @set("queryConjunction", "and")

    addQueryParam: ->
      @addQueryParam()

    deleteQuery: (sequenceNum)->
      @deleteQueryParam(sequenceNum)

    goToViewTab: ->
      @transitionToRoute("view-and-query.grid")

    goBackToSavedQueries: ->
      @transitionToRoute("view-and-query.saved-queries")

    cancelQuery: ->
      @set("model.queryParams", Ember.A([]))
      @selectAll(true)

    saveQuery: ->
      if @get("model.id") != null
        @storage.saveQuery(@get("model"))
        .then (result) =>
          @set("isSaved", true)
          @set("parentModel", @get("model").copy())
          @send "closeDialog"
      else
        @storage.validateQueryParams(@get("project.id"), @get("model"))
        .then(=>
          @send "openDialog", "save_query", @get("model"), "viewAndQueryConfirmSaveQuery"
          @positionSaveQueryPopup()
          @set("hasParamErrors", false)
        , =>
          @set("hasParamErrors", true)
        )


    submitQuery: ->
      unless @handleParamErrors()
        if @get("model").compare(@get("parentModel"))
          @set("model.isSaved", true)
        else
          @set("model.isSaved", false)
        if @get("model.queryParams.length") > 0
          @storage.validateQueryParams(@get("project.id"), @get("model"))
          .then =>
            @transitionToRoute("view-and-query.results", {queryParams: {query: @get("model")}})
            @set("hasParamErrors", false)
          , =>
            @set("hasParamErrors", true)
        else
          @transitionToRoute("view-and-query.results", {queryParams: {query: @get("model")}})
