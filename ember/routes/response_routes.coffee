LabCompass.ResponsesRoute = LabCompass.ProtectedRoute.extend
  model: ->
    @storage.findSubjectsByForm(@modelFor("form"))


  setupController: (controller, model) ->
    subjectID = controller.get("subjectID")
    if controller.get("saveSubjectID")
      Ember.run.next(=>
        controller.set("tempSubjectID", subjectID)
        controller.set("subjectID", subjectID)
        controller.set("secondaryID", null)
        controller.setSubjectID()
      )
      controller.setProperties
        model: model
        formStructure: @modelFor "form"
        subjectID: controller.get("subjectID")
        tempSubjectID: controller.get("subjectID")
        saveSubjectID: false
    else
      controller.setProperties
        model: model
        formStructure: @modelFor "form"
        subjectID: null

  sizeIdBoxes: ->
    input = $("#subject-id-input")
    box = $("#subject-id-input-box")
    input2 = $("#subject-id-input-2")
    box2 = $("#subject-id-input-box-2")
    input.css("width", (box.width() - 440) + "px")
    input2.css("width", (box.width() - 440) + "px")
    $("#instance-entry").width($("#subject-id-input").width())

  actions:
    onSaveResponse: ->
      @model().then (contents) =>
        @set 'controller.model', contents

    willTransition: (trans)->
      @_super()
      @set 'controller.subjectID', null
      @set("controller.secondaryID", null)
      $(window).off('resize', @sizeIdBoxes)
      myModel = @modelFor('project')

      if trans.targetName == "response.edit"
        @send "loadingOn"
        if myModel.get("demoProgress.enterEditSubjectId") == false
          myModel.set("demoProgress.enterEditSubjectId", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
      
      #if trans.targetName != "response.edit"
      #  try
      #    $("#enterEditJoyride").foundation('joyride','hide')

    didTransition: ->
      @_super()
      @controller.handleDemoStuff()
      Ember.run.next =>
        @sizeIdBoxes()
        @send "loadingOff"
      $(window).on('resize', @sizeIdBoxes)



LabCompass.ResponseRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    @storage.loadResponse(params.responseID)

  serialize: (model) ->
    responseID: model.id
  #  model: (params, transition) ->
  #    form = @modelFor("form")
  #    subjectID = transition.params.response.subjectID
  #    instance = null
  #    unless Ember.isEmpty params.queryParams.instance
  #      instance = params.queryParams.instance
  #    instanceParam = 0
  #    unless instance == null
  #      instanceParam = instance
  #    @storage.loadFormResponse(@modelFor("form"), subjectID, instanceParam)
  #    .then (result) ->
  #      if form.get("isManyToOne") and instance == null
  #        result.set("answers", Ember.A([]))
  #      result
 
  
LabCompass.SingleResponseRoute = LabCompass.ProtectedRoute.extend
  setupController: (controller, model) ->
    if Ember.isEmpty(controller.get("controllers.responses.subjectID"))
      controller.get("controllers.responses").setProperties
        subjectID: model.get("subjectID")
        secondaryID: model.get("secondaryId")
    controller.setProperties
      parentModel: model
      model: model.copy()
      subjectID: model.get("subjectID")


  sizeIdBoxes: ->
    input = $("#subject-id-input")
    box = $("#subject-id-input-box")
    input2 = $("#subject-id-input-2")
    box2 = $("#subject-id-input-box-2")
    input.css("width", (box.width() - 440) + "px")
    input2.css("width", (box.width() - 440) + "px")
    $("#instance-entry").width($("#subject-id-input").width())

  sizeErrorBox: ->
    necessaryWidth = $(".form-response").width()
    if necessaryWidth < 1019
      errorWidth = necessaryWidth - 369
      $($(".error-notification")[0]).css("max-width", errorWidth + "px")
    if $(".error-notification").outerHeight() > 50 && $(".error-notification").hasClass("show")
      $($(".saveSlider")[0]).css("height", $(".error-notification").outerHeight() + "px")

  sizeSaveSlider: ->
    necessaryWidth = $(".form-response").width()
    if necessaryWidth < 1019
      flashingWidth = necessaryWidth - 369
      $($("#success-flash")[0]).css("max-width", flashingWidth + "px")
    if $("#success-flash").outerHeight() > 50 && !$("#success-flash").hasClass("success hide")
      $($(".saveSlider")[0]).css("height", $("#success-flash").outerHeight() + 7 + "px")
    $($(".saveSlider")[0]).css("width", necessaryWidth + "px")

  #had issue with displaying the save slider after the model loads... as a result this function displays it
  displaySaveSlider: ->
    currentSub = $(".current-subject")
    if currentSub.length > 0
      $($(".saveSlider")[0]).css("display", "block")
    else
      window.setTimeout(=>
        @displaySaveSlider()
      , 500)

  disableScroll: ->
    if @controller.get("onMobile")
      $('#go-to-form').focus ->
        scrollAmount = $(window).scrollTop()
        $(window).scrollTop(scrollAmount)

  actions:
    willTransition: (trans) ->
      @_super()
      if @controller.handleTransition(trans)
        $(window).off('resize', @sizeIdBoxes)
        $(window).off('resize', @sizeSaveSlider)
        $(window).off('resize', @sizeErrorBox)
        parent = @controller.get("controllers.responses")
        unless parent.get("saveSubjectID")
          parent.setProperties({
            subjectID: null,
            secondaryID: null
          })
        #@controller.set("editModel", null)
      try
        $("#enterEditJoyride").foundation('joyride','hide')

    didTransition: ->
      @_super()
      @send "loadingOff"
      Ember.run.next =>
        @sizeIdBoxes()
        @sizeSaveSlider()
        @displaySaveSlider()
        @sizeErrorBox()
        @disableScroll()

      $(window).on('resize', @sizeIdBoxes)
      $(window).on('resize', @sizeSaveSlider)
      $(window).on('resize', @sizeErrorBox)

LabCompass.ResponseEditRoute = LabCompass.SingleResponseRoute.extend
  actions:
    didTransition: ->
      @_super()
      @controller.set("isErrors", false)
      @controller.set("answerErrors", [])
      @controller.handleDemoStuff()

LabCompass.ResponseViewRoute = LabCompass.SingleResponseRoute.extend()

#  actions:
#    willTransition: (trans) ->
#      @_super()
#      if @controller.get("isManyToOne")
#        @controller.set("selectedSecondaryId", null)
#      if @controller.handleTransition(trans)
#        $(window).off('resize', @sizeIdBoxes)
#        $(window).off('resize', @sizeSaveSlider)
#        $(window).off('resize', @sizeErrorBox)
#      myModel = @modelFor "project"
#      try
#        $("#enterEditJoyride").foundation('joyride','hide')
#
#    didTransition: ->
#      @_super()
#      @send "loadingOff"
#      Ember.run.next =>
#        @sizeIdBoxes()
#        @sizeSaveSlider()
#        @displaySaveSlider()
#        @sizeErrorBox()
#        @disableScroll()
#        @controller.handleDemoStuff()
#
#        form = @modelFor("form")
#        if form.get("isManyToOne")
#          $(".select-instance-row .specify-subject-box").css("box-shadow", "inset 0px 14px 20px -2px #DADADA")
#
#      $(window).on('resize', @sizeIdBoxes)
#      $(window).on('resize', @sizeSaveSlider)
#      $(window).on('resize', @sizeErrorBox)

#LabCompass.InstanceEditRoute = LabCompass.ProtectedRoute.extend
#  model: (params, transition) ->
#    subjectID = transition.params.response.subjectID
#    form = @modelFor("form")
#    instance = parseInt(transition.params.instance.instance)
#    instanceParam = 0
#    unless instance == -1
#      instanceParam = instance
#
#    # TODO: change to only load if one to one or instance declared
#    if !Ember.isEmpty(params.queryParams.isNew) and params.queryParams.isNew
#      retModel = null
#      try
#        retModel = params.queryParams.newModel
#      catch
#        @transitionTo "response.instance", subjectID, -1
#      retModel
#    else
#      @storage.loadFormResponse(@modelFor("form"), subjectID, instanceParam)
#      .then (result) =>
#        if result.id == null and instance != -1
#          @transitionTo "instance.edit", -1
#        if form.get("isManyToOne") and instance == -1
#          #result.set("answers", Ember.A([]))
#          result.set("secondaryId", null)
#          result.set("isDisplayed", false)
#        else
#          result.set("isDisplayed", true)
#        result
#      , (error) ->
#        @transitionTo "instance.edit", -1
#
#  # serialize: (model) ->
#  #   {
#  #     subjectID: model.get('subjectID')
#  #     instance: model.get("instanceNumber")
#  #   }
#
#  setupController: (controller, model) ->
#    newModel = model.copy()
#    newModel.set("allInstances", model.get("allInstances"))
#    newModel.set("isDisplayed", model.get("isDisplayed"))
#    controller.setProperties
#      parentModel: model
#      model: newModel
#      jumpToForm: null
#      subjectID: model.get("subjectID")
#      selectedSecondaryId: null
#
#  #had issue with displaying the save slider after the model loads... as a result this function displays it
#  displaySaveSlider: ->
#    currentSub = $(".current-subject")
#    if currentSub.length > 0
#      $($(".saveSlider")[0]).css("display", "block")
#    else
#      window.setTimeout(=>
#        @displaySaveSlider()
#      , 500)
#

#
#  sizeSaveSlider: ->
#    necessaryWidth = $(".form-response").width()
#    if necessaryWidth < 1019
#      flashingWidth = necessaryWidth - 369
#      $($("#success-flash")[0]).css("max-width", flashingWidth + "px")
#    if $("#success-flash").outerHeight() > 50 && !$("#success-flash").hasClass("success hide")
#      $($(".saveSlider")[0]).css("height", $("#success-flash").outerHeight() + 7 + "px")
#    $($(".saveSlider")[0]).css("width", necessaryWidth + "px")
#
#  sizeErrorBox: ->
#    necessaryWidth = $(".form-response").width()
#    if necessaryWidth < 1019
#      errorWidth = necessaryWidth - 369
#      $($(".error-notification")[0]).css("max-width", errorWidth + "px")
#    if $(".error-notification").outerHeight() > 50 && $(".error-notification").hasClass("show")
#      $($(".saveSlider")[0]).css("height", $(".error-notification").outerHeight() + "px")
#
#  disableScroll: ->
#    if @controller.get("onMobile")
#      $('#go-to-form').focus ->
#        scrollAmount = $(window).scrollTop()
#        $(window).scrollTop(scrollAmount)
#
#  actions:
#    willTransition: (trans) ->
#      @_super()
#      if @controller.get("isManyToOne")
#        @controller.set("selectedSecondaryId", null)
#      if @controller.handleTransition(trans)
#        $(window).off('resize', @sizeIdBoxes)
#        $(window).off('resize', @sizeSaveSlider)
#        $(window).off('resize', @sizeErrorBox)
#      myModel = @modelFor "project"
#      try
#        $("#enterEditJoyride").foundation('joyride','hide')
#
#    didTransition: ->
#      @_super()
#      @send "loadingOff"
#      Ember.run.next =>
#        @sizeIdBoxes()
#        @sizeSaveSlider()
#        @displaySaveSlider()
#        @sizeErrorBox()
#        @disableScroll()
#        @controller.handleDemoStuff()
#
#        form = @modelFor("form")
#        if form.get("isManyToOne")
#          $(".select-instance-row .specify-subject-box").css("box-shadow", "inset 0px 14px 20px -2px #DADADA")
#
#      $(window).on('resize', @sizeIdBoxes)
#      $(window).on('resize', @sizeSaveSlider)
#      $(window).on('resize', @sizeErrorBox)
#
#LabCompass.InstanceIndexRoute = LabCompass.ProtectedRoute.extend
#   model: (params, transition) ->
#    subjectID = transition.params.response.subjectID
#    form = @modelFor("form")
#    instance = parseInt(transition.params.instance.instance)
#    instanceParam = 0
#    unless instance == -1
#      instanceParam = instance
#    # TODO: change to only load if one to one or instance declared
#    retObj = null
#    @storage.loadFormResponse(@modelFor("form"), subjectID, instanceParam)
#    .then (result) =>
#      if result.id == null and instance != -1
#        @transitionTo "instance.edit", -1
#      if form.get("isManyToOne") and instance == -1
#        #result.set("answers", Ember.A([]))
#        result.set("secondaryId", null)
#        result.set("isDisplayed", false)
#      else
#        result.set("isDisplayed", true)
#      return result
#    , (error) ->
#      @transitionTo "instance.edit", -1
#      return retObj
#
#  setupController: (controller, model) ->
#    controller.setupDisplayedQuestions()
#    controller.set('jumpToForm', null)
#
#  sizeIdBoxes: ->
#    input = $("#subject-id-input")
#    box = $("#subject-id-input-box")
#    input2 = $("#subject-id-input-2")
#    box2 = $("#subject-id-input-box-2")
#    input.css("width", (box.width() - 440) + "px")
#    input2.css("width", (box.width() - 440) + "px")
#    $("#instance-entry").width($("#subject-id-input").width())
#
#  sizeSaveSlider: ->
#    necessaryWidth = $(".form-response").width()
#    if necessaryWidth < 1019
#      flashingWidth = necessaryWidth - 369
#      $("#success-flash")[0].style.maxWidth = flashingWidth + "px"
#    if $("#success-flash").outerHeight() > 50 && !$("#success-flash").hasClass("success hide")
#      $(".saveSlider")[0].style.height = $("#success-flash").outerHeight() + 7 +  "px"
#    $(".saveSlider")[0].style.width = necessaryWidth + "px"
#    $(".saveSlider")[0].style.display = "block"
#
#  sizeErrorBox: ->
#    necessaryWidth = $(".form-response").width()
#    if necessaryWidth < 1019
#      errorWidth = necessaryWidth - 369
#      $(".error-notification")[0].style.maxWidth = errorWidth + "px"
#    if $(".error-notification").outerHeight() > 50 && $(".error-notification").hasClass("show")
#      $(".saveSlider")[0].style.height = $(".error-notification").outerHeight() + 7 + "px"
#
#  actions:
#    willTransition: (trans) ->
#      @_super()
#      if @controller.handleTransition(trans)
#        $(window).off('resize', @sizeIdBoxes)
#        $(window).off('resize', @sizeSaveSlider)
#        $(window).off('resize', @sizeErrorBox)
#
#    didTransition: ->
#      @_super()
#      Ember.run.next =>
#        @sizeIdBoxes()
#        @sizeSaveSlider()
#        @sizeErrorBox()
#        @disableScroll()
#      $(window).on('resize', @sizeIdBoxes)
#      $(window).on('resize', @sizeSaveSlider)
#      $(window).on('resize', @sizeErrorBox)
