LabCompass.FormDataTabHandler = Ember.Object.extend
  parentController: null

  formTabWidth: 180
  minimumTabs: 2
  firstShownTabIndex: 0

  tabArrowEnabled: false
  tabArrowHasAdd: false

  canScrollTabsRight: false
  canScrollTabsLeft: false
  tabScrollAmount: 2

  numTabs: 2

  isWiderThanGrid: false

  # gets called by slickHandler.resizeWidth()
  setIsWiderThanGrid: (->
    totalWidth = @formTabWidth * @numTabs
    gridWidth = $(".left-pane").width() + $(".right-pane").width()
    @set("isWiderThanGrid", totalWidth >= gridWidth)
  ).observes("numTabs")

  # gets called by controller.doDelayResize()
  resetNumTabs: (->
    if $(".outer-grid-container").length == 0
      Ember.run.schedule("afterRender", =>
        @setNumTabs()
      )
    else
      @setNumTabs()
  ).observes("parentController.model.length")

  setNumTabs: ->
    numTabs = Math.max(
      Math.floor($(".outer-grid-container").width() / @get("formTabWidth")),
      @get("minimumTabs")
    )
    @set("numTabs", numTabs)
    model = @get("parentController.model")
    contentLength = model.get("length")
    if @get("firstShownTabIndex") + numTabs > contentLength
      newIndex = Math.max(contentLength - numTabs, 0)
      @set("firstShownTabIndex", newIndex)


  formTabs: (->
    retArr = []
    model = @get("parentController.model")
    contentLength = model.get("length")
    if @get("numTabs") <= contentLength
      @set("tabArrowsEnabled", true)
      @set("tabArrowHasAdd", true)
    else
      @set("tabArrowsEnabled", false)
      @set("tabArrowHasAdd", false)
    #if @get("numTabs") + @get("firstShownTabIndex") <= contentLength
    #  @set("tabArrowHasAdd", true)
    #else
    #  @set("tabArrowHasAdd", false)
    for i in [@get("firstShownTabIndex")...(@get("numTabs") + @get("firstShownTabIndex"))]
      tabObj = @defaultTabObj()
      if i < @get("firstShownTabIndex")
        continue
      if i == contentLength and @get("tabArrowHasAdd") == false
        tabObj.isAddNewTab = true
        retArr.push(tabObj)
      else if i < contentLength
        curModel = model[i]
        name = curModel.get("formName")
        tabObj.name = name
        tabObj.canView = curModel.get("canView")
        tabObj.colorStyle = "border-top-color: #{curModel.get("color")}"
        if curModel.get("formID") == @get("parentController.activeModel.formID")
          tabObj.isActiveTab = true
          retArr.push(tabObj)
        else
          tabObj.isInactiveTab = true
          retArr.push(tabObj)
      else
        break
    retArr
  ).property("numTabs", "firstShownTabIndex", "parentController.activeModel.canView")

  defaultTabObj: () ->
    Ember.Object.create({
      isActiveTab: false,
      isInactiveTab: false,
      isAddNewTab: false,
      name: "",
      canView: true,
      colorStyle: ""
    })

  updateTabs: ->
    @notifyPropertyChange("numTabs") # allows tabs to reset

  setCanScroll: (->
    if @get("firstShownTabIndex") > 0
      @set("canScrollTabsLeft", true)
    else
      @set("canScrollTabsLeft", false)
    allowedActiveTabs = @get("numTabs") - 1 #accounts for add form
    if @get("parentController.content.length") - allowedActiveTabs > @get("firstShownTabIndex")
      @set("canScrollTabsRight", true)
    else
      @set("canScrollTabsRight", false)
  ).observes("numTabs", "firstShownTabIndex", "parentController.content.length")

  decrementFirstTabShown: ->
    amount = @get("tabScrollAmount")
    curIndex = @get("firstShownTabIndex")
    if curIndex - amount <= 0
      @set("firstShownTabIndex", 0)
    else
      @set("firstShownTabIndex", curIndex - amount)

  incrementFirstTabShown: ->
    amount = @get("tabScrollAmount")
    curIndex = @get("firstShownTabIndex")
    allowedActiveTabs = @get("numTabs") - 1 #accounts for add form
    numForms = @get("parentController.content.length")
    if curIndex + amount >= numForms - allowedActiveTabs
      @set("firstShownTabIndex", numForms - allowedActiveTabs)
    else
      @set("firstShownTabIndex", curIndex + amount)