LabCompass.ProjectFormDataController = Ember.ArrayController.extend LabCompass.WithProject,
  breadCrumb: "Data"
  setBreadCrumb: (->
    formName = @get("activeModel.formStructure.name")
    if Ember.isEmpty(formName)
      @set("breadCrumb", "Data")
    else
      newCrumb = "Data - " + formName
      @set("breadCrumb", newCrumb)
  ).observes("activeModel.formStructure")

  activeModel: null

  slickHandler: null

  projectID: null

  curFilterString: ""
  tempCurFilterString: ""
  filterTypingTimer: null
  curFilterVariable: ""
  curSortType: ""
  curSortVariable: ""
  isModelChange: false
  isDirty: true

  subjectCountHidden: true

  totalRows: null
  displayedRows: null
  hasNoFilterResults: false
  blockGridActions: false

  isGridBlocked: false
  setIsGridBlocked: (->
    isBlocked = ((@get("content.length") == 0) or
                  @get("activeModel.hasNoData") or
                  @get("isLoadingRequest") or
                  @get("hasNoFilterResults"))
    @set("isGridBlocked", isBlocked)
    if @get("content.length") == 0 or @get("activeModel.hasNoData")
      @set("blockGridActions", true)
    else
      @set("blockGridActions", false)
  ).observes("model", "activeModel", "isLoadingRequest", "hasNoFilterResults")

  setCurFilter: (->
    clearTimeout(@get("filterTypingTimer"))
    @set("filterTypingTimer", window.setTimeout( =>
      @set("curFilterString", @get("tempCurFilterString"))
    , 500))
  ).observes("tempCurFilterString")

  isLoadingRequest: false
  actionHandler: null
  tabHandler: null

  activeColumn: null

  sortMenuItems: [
    {class: "ascUnfilledFirst", title: "A-Z 0-9 unfilled first"},
    {class: "descUnfilledFirst", title: "Z-A 9-0 unfilled first"},
    {class: "ascUnfilledLast", title: "A-Z 0-9 unfilled last"},
    {class: "descUnfilledLast", title: "Z-A 9-0 unfilled last"}
  ]

  subjectOnlySortItems: [
    {class: "subjFirstCreated", title: "First created on top"},
    {class: "subjLastCreated", title: "Last created on top"},
    {class: "subjFirstUpdated", title: "First edited on top"},
    {class: "subjLastUpdated", title: "Last edited on top"}
  ]

  init: ->
    @set("actionHandler", new LabCompass.FormDataActionHandler())
    @set("actionHandler.parentController", @)
    @set("slickHandler", new LabCompass.FormDataSlickHandler())
    @set("slickHandler.parentController", @)
    @set("tabHandler", new LabCompass.FormDataTabHandler())
    @set("tabHandler.parentController", @)

    if @get("session.user.format") == false
      @doOnboarding()
    else if @get("session.user.clean") == false
      @doOnboarding2()
    else if @get("session.user.invite") == false
      @doOnboarding3()

  doOnboarding: ->
    id = $("span:contains('Email')").parent().attr("id")

    if $("#"+id).length > 0
      $("#"+id).attr("title", "Add structure by setting the format of the data. Give it a try!")
      $(document).ready ->
        $("#"+id).qtip
          show: 
            when: false
            ready: true
          hide: false
          content: button: 'Close'
          style: { classes: 'qtip-jtools' }

    else
      window.setTimeout(=>
        @doOnboarding()
      , 1000)

  doOnboarding2: ->
    $(".qtip").remove()

    $(".error-content").on "click", =>
      $(".qtip").remove()

    if $(".error-content").length > 0
      $(".error-content").attr("title", "Click here to find errors and fix them")
      $(document).ready ->
        $(".error-content").qtip
          show: 
            when: false
            ready: true
          hide: false
          content: button: 'Close'
          style: { classes: 'qtip-jtools' }
    else
      window.setTimeout(=>
        @doOnboarding2()
      )

  doOnboarding3: ->
    $(".qtip").remove()

    $(".teamText").on 'click', =>
      $(".qtip").remove()
    
    if $(".teamText").length > 0
      $(".teamText").attr("title", "Use the My Team page to manage collaborators.  Click here to invite your collaborators and set user access permissions!")
      $(document).ready ->
        $(".teamText").qtip
          show: 
            when: false
            ready: true
          hide: false
          content: button: 'Close'
          style: { classes: 'qtip-jtools' }
    else
      window.setTimeout(=>
        @doOnboarding3()
      )

  triggerOnboarding2: (->
    if @get("session.user.format") == true
      @doOnboarding2()
  ).observes("session.user.format")

  triggerOnboarding3: (->
    if @get("session.user.clean") == true
      @doOnboarding3()
  ).observes("session.user.clean")

  setWindowEvents: ->
    $(window).on("resize", {context: @}, @doDelayResize)

  unsetWindowEvents: ->
    $(window).off("resize", @doDelayResize)


  windowResizeTimer: null

  doDelayResize: (event) ->
    context = event.data.context
    clearTimeout(context.get("windowResizeTimer"))
    context.set("windowResizeTimer", window.setTimeout( =>
      context.get("slickHandler").resizeWidth()
      context.get("slickHandler").resizeHeight()
      context.get("tabHandler").resetNumTabs()
    , 500))


  requestNewRender: (reloadColumns=false) ->
    if @get("activeModel.isCompleted")
      @get("activeModel").reconstructGrids()
      @get("slickHandler").reRenderGrids(reloadColumns)
    else
      @set("isLoadingRequest", true)

  updateFilter: (->
    curString = @get("curFilterString")
    curVariable = @get("curFilterVariable")
    @get("actionHandler").doAction("filter", [curString, curVariable])
    @updateRowCount()
  ).observes("curFilterString", "curFilterVariable")

  updateSort: (->
    sortType = @getSortType(@get("curSortType"))
    sortVar = @get("curSortVariable")
    isSubject = (sortVar == "subjectID")
    @checkForSubjectSort(isSubject)
    if Ember.isEmpty(sortType) or Ember.isEmpty(sortVar)
      return
    @get("actionHandler").doAction("sort", [sortType, sortVar])
  ).observes("curSortType", "curSortVariable")

  checkForSubjectSort: (isSubject) ->
    menu = @get("sortMenuItems")
    if isSubject and menu.length == 4
      menu.pushObjects(@get("subjectOnlySortItems"))
    else if isSubject == false and menu.length > 4
      while menu.length > 4
        menu.popObject()

  setupFromNewModel: (->
    @set("isModelChange", true)
    @set("curFilterString", @get("activeModel.filterString"))
    @set("curFilterVariable", @get("activeModel.filterVariable"))
    @set("curSortType", @get("activeModel.sortTypeStr"))
    @set("curSortVariable", @get("activeModel.sortVariable"))
    Ember.run.next( =>
      @set("isModelChange", false)
    )
  ).observes("activeModel")

  variableNames: (->
    result = []
    unless @get("activeModel") == null or @get("activeModel.hasNoData")
      result = Ember.A(["Subject ID"])
      unless Ember.isEmpty(@get("activeModel.secondaryId"))
        result.push(@get("activeModel.secondaryId"))
      for column in @get("activeModel.rightColumns")
        result.push(column.field)
    result
  ).property("activeModel", "activeModel.rightColumns")

  filterVariableNames: (->
    retArray = @get("variableNames").slice()
    retArray.unshift("All Data")
    retArray
  ).property("variableNames")

  numFormsLoaded: 0

  allFormsLoaded: false

  setAllFormsLoaded: (->
    val = (@get("numFormsLoaded") >= @get("project.structures.content.length"))
    @set("allFormsLoaded", val)
  ).observes("numFormsLoaded")

  loadData: (formID, willRender) ->
    curModel = null
    for formData in @get("model")
      if formData.get("formID") == formID
        curModel = formData
    if curModel == null
      console.error "no models match id: #{formID}"
      return null
    if willRender
      @set("isLoadingRequest", true)
    @get("storage").getInitialFormData(formID).then( (result) =>
      data = result.body
      curModel.setProperties({
        isCompleted: result.isCompleted,
        initialSize: result.initialSize,
        canView: result.canView
      })
      curModel.initErrors(result.errors, result.numErrors)
      curModel.loadHeaders(result.header.left, result.header.right)

      leftColumns = ["subjectID"]
      unless Ember.isEmpty(curModel.get("secondaryId"))
        leftColumns.push(curModel.get("secondaryId").split(" ").join("_"))
      curModel.loadData(data, leftColumns)
      #leftData = curModel.get("leftData")
      #rightData = curModel.get("rightData")
      if willRender
        Ember.run.next( =>
          @get("slickHandler").setSlickGrid()
          @get("slickHandler").reRenderGrids()
          @updateRowCount()
          @set("isLoadingRequest", false)
          unless curModel.get("isCompleted")
            @getRemainingData()
          @get("slickHandler").renderInitial()
        )
      @get("storage").setFormDataFormStructure(curModel)
      @incrementProperty("numFormsLoaded")
    )

  getRemainingData: ->
    @setViewLoading()
    @get("storage").getRemainingFormData(@get("activeModel.formID"))
    .then (result) =>
      activeModel = @get("activeModel")
      if activeModel.get("formID") == result.formID and activeModel.get("isCompleted") == false
        activeModel.addRemainingData(result.body)
        @get("slickHandler").reRenderGrids(false)
        @updateRowCount()
        @set("isLoadingRequest", false)
        @unsetViewLoading()

  updateRowCount: ->
    if Ember.isEmpty(@get("model")) or Ember.isEmpty(@get("activeModel"))
      return
    dataDriver = @get("activeModel.dataDriver")
    if @get("activeModel.isCompleted")
      @set("totalRows", dataDriver.get("data.length"))
    else
      @set("totalRows", null)
    @set("displayedRows", (dataDriver.get("leftGrid.length") - dataDriver.get("numEmptyRows")))
    @set("subjectCountHidden", !@isSubjectCountDisplayed())

  isSubjectCountDisplayed: ->
    totalRows = @get("totalRows")
    rowCount = @get("displayedRows")
    if totalRows == null or totalRows == 0
      return false
    if rowCount == 0
      @set("hasNoFilterResults", true)
      return true
    @set("hasNoFilterResults", false)
    if rowCount >= totalRows
      return false
    return true

  setViewLoading: ->
    @addLoadingDivToBottom()

  unsetViewLoading: ->
    $(".loading-more").remove()

  addLoadingDivToBottom: ->
    rightCanvas = $(".right-pane .slick-viewport .grid-canvas")
    $("<div></div>", {
      text: "Loading Data...",
      class: "loading-more"
    }).appendTo(rightCanvas)
    leftCanvas = $(".left-pane .slick-viewport .grid-canvas")
    $("<div></div>", {
      class: "loading-more"
    }).appendTo(leftCanvas)


  constructSortMenu: (event, isSubject) ->
    $(".sort-menu").remove()
    grid = $(".outer-grid-container")
    elem = $(event.currentTarget)
    left = (elem.offset().left + elem.width()) - grid.offset().left + 25
    if left + elem.width() > grid.width()
      left = (elem.offset().left - 178) - grid.offset().left
    newPos = {
      top: (elem.offset().top) - grid.offset().top,
      left: left
    }
    $sortMenu = $("<ul></ul>", {
      class: "sort-menu"
      css: {
        left: newPos.left,
        top: newPos.top
      }
    })
    for menuObj in @get("sortMenuItems")
      $("<li></li>", {
        class: "sort-menu-item",
        text: menuObj.title,
        "data-type": menuObj.class
      }).appendTo($sortMenu)
    $sortMenu


  setSortEvents: ->
    controller = @
    $(".outer-grid-container").on("click", ".sort-menu-item", (e) ->
      sortType = $(e.currentTarget).attr("data-type")
      sortVariable = controller.get("activeColumn").field
      controller.get("actionHandler").doAction("sort", [sortType, sortVariable])
    )

  resetGrid: ->
    @get("slickHandler").reRenderGrids()
    Ember.run.scheduleOnce("afterRender", =>
      try
        $(document).foundation()
    )
    unless @get("activeModel.isCompleted")
      @getRemainingData()





  getQuestionIDFromCell: (grid, colNum) ->
    grid.getColumns()[colNum].id

  getResponseIDFromCell: (rowNum) ->
    @get("activeModel.dataDriver.responseIDByRow")[rowNum]

  getQuestionFromID: (questionID) ->
    form = @get("activeModel.formStructure")
    question = form.get("questions").findBy("id", questionID)
    return question


  getSortType: (sortTypeStr) ->
    for menuItem in @get("sortMenuItems")
      if menuItem.title == sortTypeStr
        return menuItem.class
    return ""


  createFormDataFromForm: (form) ->
    newFormData = @get("storage").createModel("formData")
    leftHeader = [
      {
        id:"subject-id",
        name:"Subject ID",
        field:"subjectID"
      }
    ]
    newFormData.setProperties({
      formID: form.id,
      formName: form.get("name"),
      formStructure: form,
      initialSize: 250,
      dataDriver: new LabCompass.GridDataDriver(),
      curSortVariable: "Subject ID",
      secondaryId: form.get("secondaryId"),
      isCompleted: true,
      hasNoData: true,
      canView: true,
      answerErrors: @storage.createModel("formDataErrors")
    })
    newFormData.loadHeaders(leftHeader, [])
    newFormData.loadData([], ["subjectID"])

  openTargetDataCleanup: (targetQuestionID, targetResponseID) ->
    activeModel = @get("activeModel")
    activeModel.set("curErrorQuestionID", targetQuestionID)
    activeModel.set("curErrorResponseID", targetResponseID)
    activeModel.notifyPropertyChange("curErrorResponseID") # allows dialog controller to reset
    activeModel.notifyPropertyChange("curErrorQuestionID")
    context = @

    $(document).one("opened", "[data-reveal]", (->
      unless Ember.isEmpty(targetResponseID)
        $targetInput = $("." + targetResponseID)
        $targetInput.focus()
        $targetInput.select()
        $targetInput.get(0).scrollIntoView()
      $("textarea.ember-text-area").each( ->
        $(this).height($(this).outerHeight())
      )
      $targetBG = $(".reveal-modal-bg")
      $newBG = $("<div class='form-data-cleanup-bg'</div>")
      $targetBG.parent().append($newBG)
      $targetBG.hide()
      $(".data-cleanup-modal").css("min-height", $(window).height() - 70)
      if $(window).height() >= 550
        $(".data-cleanup-modal").css("top", "30px")
        $(window).scrollTop(0)
        $("body").css("overflow", "hidden")
        heightDiff = $(window).height() - 550
        $(".body-wrapper").css("max-height", 130 + heightDiff)
    ))
    $(document).one("closed", "[data-reveal]", ->
      $(".form-data-cleanup-bg").remove()
      $(".reveal-modal-bg").hide()
      $("body").css("overflow", "visible")
    )
    @send("openDialog", "clean_data", activeModel, "cleanDataDialog")


  setGridErrorFormatting: ->
    rightGrid = @get("slickHandler.rightGrid")
    @get("slickHandler").setGridErrorFormatting(rightGrid)


  actions:
    goToForm: (formName) ->
      formData = @get("content").findBy("formName", formName)
      @get("actionHandler").doAction("goToForm", [formData])

    saveQuestion: (question, formatObject) ->
      @get("actionHandler").doAction("changeQuestion", [question, formatObject])

    addForm: ->
      newForm = @get("storage").createModel("formStructure")
      newForm.set("isFromGrid", true)
      @send("openDialog", "create_form_structure", newForm, "projectCreateFormStructure")

    addNewFormData: (form, keepForm) ->
      newFormData = null
      if @get("content.length") == 0
        @get("slickHandler").setSlickGrid()
      if keepForm
        newFormData = @createFormDataFromForm(form)
        @get("content").pushObject(newFormData)
      else
        if form.get("isManyToOne")
          newFormData = @get("content.lastObject")
          newFormData.updateFormStructure(form)
        else
          newFormData = @createFormDataFromForm(form)
          @get("content").pushObject(newFormData)
        @send("closeDialog")
        Ember.run.next(=>
          @get("actionHandler").doAction("goToForm", [newFormData])
        )

    openDataCleanup: ->
      @openTargetDataCleanup(null, null)

    scrollTabsLeft: ->
      @get("tabHandler").decrementFirstTabShown()

    scrollTabsRight: ->
      @get("tabHandler").incrementFirstTabShown()

    openFormSettings: ->
      form = @get("activeModel.formStructure")

    deleteQuestion: (question) ->
      @get("activeModel").deleteColumn(question)
      @storage.deleteQuestion(@get("activeModel.formStructure"), question)
      @get("activeModel.answerErrors").updateNumErrors()
      @requestNewRender(true)
      @send("closeDialog")

    export: ->
      exportQuery = @storage.createNewQuery(@get("project"))
      exportQuery.set("hasBlockedForms", false) #TODO: implement this
      for queriedForm in exportQuery.get(".queriedForms.content")
        unless queriedForm.get("formID") == @get("activeModel.formID")
          queriedForm.set("included", false)
      @send "openDialog", "confirm_download_project_grid", exportQuery, "confirmDownloadDialog"

    dataDownloaded: ->
      @send "closeDialog"

    codebook: ->
      codebookQuery = @storage.createNewQuery(@get("project")) # used for form checkboxes
      #codebookQuery.set("hasBlockedForms", @get("model.hasBlockedForms")) TODO: implement this
      for queriedForm in codebookQuery.get(".queriedForms.content")
        unless queriedForm.get("formID") == @get("activeModel.formID")
          queriedForm.set("included", false)
      @send("openDialog", "confirm_download_codebook", codebookQuery, "confirmDownloadCodebook")

    codebookDownloaded: ->
      @send "closeDialog"


    editSecondaryId: ->
      form = @get("activeModel.formStructure")
      @get("actionHandler").doAction("editSecondaryId", [form])

    updateSecondaryID: (form) ->
      oldForm = @get("activeModel.formStructure")
      if form.get("isManyToOne") == true and oldForm.get("isManyToOne") == false
        newId = form.get("secondaryId")
        @get("activeModel").addColumn(newId, newId, newId, true)
      else if form.get("isManyToOne") == false and oldForm.get("isManyToOne") == true
        @get("activeModel").deleteSecondaryIdColumn()
      else if form.get("secondaryId") != oldForm.get("secondaryId")
        try
          @get("activeModel.leftColumns")[1].name = form.get("secondaryId")
      @get("activeModel").updateFormStructure(form, @get("project"))
      @get("storage").loadProject(@get("project.id"))
      .then (newProject) =>
        @set("project", newProject)
        @container.lookup("controller:projectIndex").set("model", newProject)
        @container.lookup("controller:project").set("model", newProject)
      @requestNewRender(true)

    updateSecondaryIdNames: (name) ->
      newId = @get("activeModel.formStructure.secondaryId")
      @get("activeModel.dataDriver").addColumnWithDefault(newId, name)
      @requestNewRender(false)

    import: (form)->
      # TODO: include form in the transition somehow
      @transitionToRoute "project.import" ,{queryParams: {form_from_trans: form}}

    buildForm: (form) ->
      @transitionToRoute "form.build", form.id

    renameFormStructure: ->
      form = @get("activeModel.formStructure")
      form.set("fromFormData", true)
      @send("openDialog", "rename_form_structure", form, "renameFormStructure")

    updateFormName: (newForm) ->
      @get("activeModel").updateFormStructure(newForm)
      @get("tabHandler").updateTabs()


    confirmDeleteFormStructure: ->
      @send("openDialog", "confirm_delete_form", @get('model'), "confirmDeleteForm", this)

    deleteFormStructure: ->
      deleteAnimationDelay = 0

      Ember.run.later( =>
        form = @get("activeModel.formStructure")
        @send "closeDialog"
        curModelIndex = @get("model").indexOf(@get("activeModel"))
        if curModelIndex == -1
          console.error "active model not found in model array"
          return
        goToIndex = 0
        if curModelIndex == 0
          goToIndex = 1
        if @get("model.length") > 1
          @get("actionHandler").doAction("goToForm", [@get("model")[goToIndex]])
          @get("model").splice(curModelIndex, 1)
        else
          @set("activeModel.hasNoData", false)
          @set("model", [])
          @get("slickHandler").setGridToEmpty()
        @storage.deleteFormStructure(@get("project"), form)
        @get("tabHandler").updateTabs()
      , deleteAnimationDelay)
      # TODO: implement animation

    closeDataCleanDialog: (needsReRender) ->
      if needsReRender
        @requestNewRender()
      #@get("slickHandler").setGridErrorFormatting()
      @send "closeDialog"





