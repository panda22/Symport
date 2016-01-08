LabCompass.ResponsesController = Ember.ArrayController.extend LabCompass.WithProject,

  needs: ["response", "project", "form"]
  response: Ember.computed.alias "controllers.response.model"

  breadCrumb: null

  formStructure: null

  subjectID: null

  tempSubjectID: ""

  secondaryID: null

  tempSecondaryID: null

  responseID: null

  activeModel: null

  showBottomComboBox: false

  saveSubjectID: false

  updateShowBottomComboBox: (->
    if @get("formStructure.isManyToOne")
      if Ember.isEmpty(@get("secondaryID"))
        Ember.run.scheduleOnce("afterRender", =>
          @set("showBottomComboBox", false)
        )
      else
        Ember.run.scheduleOnce("afterRender", =>
          @set("showBottomComboBox", true)
        )
    else
      if Ember.isEmpty(@get("subjectID"))
        Ember.run.scheduleOnce("afterRender", =>
          @set("showBottomComboBox", false)
        )
      else
        Ember.run.scheduleOnce("afterRender", =>
          @set("showBottomComboBox", true)
        )
  ).observes("secondaryID", "subjectID")

  responseRouteLoaded: true # used to render bottom combo box after response

  resizeComboBox: (->
    if @get("showBottomComboBox")
      input2 = $("#subject-id-input-2")
      box2 = $("#subject-id-input-box-2")
      input2.css("width", (box2.width() - 440) + "px")
  ).observes("showBottomComboBox")

  resizeSecondaryBox: (->
    if @get("formStructure.isManyToOne") and !Ember.isEmpty(@get("subjectID"))
      Ember.run.next(->
        $("#instance-entry").width($("#subject-id-input").width())
        $("#subject-id-input-box").addClass("manyToOneBoxShadow")
      )
    else
      $("#subject-id-input-box").removeClass("manyToOneBoxShadow")
  ).observes("subjectID")



  setupTempSubjectID: (->
    @set("tempSubjectID", @get("subjectID"))
  ).observes "subjectID"

  setupSecondaryID: (->
    @set("tempSecondaryID", @get("secondaryID"))
  ).observes "secondaryID"

  myHeader: null

  isInstanceSelected: false

  subjectIDs: []

  setSubjectIDs: (->
    arr = []
    for subject in @get("content")
      arr.push(subject.subjectID)
    @set("subjectIDs", arr)
  ).observes("model", "model.length")

  secondaryIds:(->
    if @get("activeModel") == null
      return []
    responses = @get("activeModel.responses")
    responses.map( (responseObj) ->
      responseObj.secondaryID
    )
  ).property("activeModel")

  #  setIsInstanceSelected: (->
  #    if @get("formStructure.questions.length") == 0
  #      @set("isInstanceSelected", false)
  #    else if !@get("formStructure.isManyToOne") and @get("subjectID") != null
  #      @set("isInstanceSelected", @get("response.isDisplayed") || false)
  #    else
  #      if @get("subjectID") == null
  #        @set("isInstanceSelected", false)
  #      else
  #        @set("isInstanceSelected", @get("response.isDisplayed") || false)
  #  ).observes 'model', 'response', 'subjectID'

  setHeaders: (->
    if @get("formStructure.userPermissions.canOnlyViewData")
      @set "myHeader", "View Form Data"
      @set "breadCrumb", "View Form Data - Form View"
    else
      @set "myHeader", "Enter/Edit Data"
      @set "breadCrumb", "Enter/Edit Data - Form View"
  ).observes 'formStructure.userPermissions.canOnlyViewData'

  error: ""
  hasError: (->
    !Ember.isEmpty @get('error')
  ).property("error")

  resetError: (->
    @set "error", ""
  ).observes "subjectID"

  noID: (->
    if Ember.isEmpty @get('responses')
      @set subjectID, ""
  ).observes 'responses'

  focusFirst: =>
    window.setTimeout(=>
      try
        document.getElementsByClassName("edit-answer-field")[0].focus()
      catch
        window.setTimeout(=>
          try
            document.getElementsByClassName("edit-answer-field")[0].focus()
          catch
        , 100)
    , 100)

    
  canEnterData: Ember.computed.alias("formStructure.userPermissions.enterData")

  handleDemoStuff: ->
    Ember.run.next(=>
      myModel = @get('project')
      myForm = @get('formStructure')
      if myModel.get("demoProgress.demoFormId") == myForm.get("id")
        if myModel.get("demoProgress.formEnterEdit") == true
          if myModel.get("demoProgress.enterEditProgress") == false
            if myModel.get("demoProgress.enterEditSubjectId") == false
              $("#enterEditJoyride").foundation('joyride','off')
              $("#enterEditJoyride").foundation('joyride', 'start')
              nextButtons = $(".joyride-next-tip")
              tooltips = $(".joyride-tip-guide")
              $(nextButtons[0]).css("visibility", "hidden")
            else
              $("#enterEditJoyride").foundation('joyride','off')
              $("#enterEditJoyride").foundation('joyride', 'start')
              tooltips = $(".joyride-tip-guide")
              $(tooltips[0]).css("visibility", "hidden")
            $(".joyride-close-tip").remove()
    )

  goToResponse: ->
    route = if @get('canEnterData') then "response.edit" else "response.view"
    responseID = @get("responseID")
    if Ember.isEmpty(responseID) # create response
      subjectID = @get("subjectID")
      secondaryID = @get("secondaryID")
      form = @get("formStructure")
      @send("loadingOn")
      @set("responseRouteLoaded", false)
      @storage.createResponse(form, subjectID, secondaryID)
      .then (formResponse) =>
        @setupNewResponse(formResponse)
        @transitionToRoute(route, formResponse)
        @send("loadingOff")
        Ember.run.next( =>
          @set("responseRouteLoaded", true)
        )
    else # load response
      @send("loadingOn")
      @set("responseRouteLoaded", false)
      @storage.loadResponse(responseID)
      .then (formResponse) =>
        @transitionToRoute(route, formResponse)
        @send("loadingOff")
        Ember.run.next( =>
          @set("responseRouteLoaded", true)
        )

  setupNewResponse: (formResponse) ->
    subjectID = @get("subjectID")
    secondaryID = @get("secondaryID")
    newResponseObj = {
      secondaryID: secondaryID,
      responseID: formResponse.id
    }
    if @get("activeModel") == null
      newModelObj = {
        subjectID: subjectID,
        responses: []
      }
      @get("model").pushObject(newModelObj)
      @set("activeModel", newModelObj)
    @get("activeModel.responses").pushObject(newResponseObj)

  setSubjectID: ->
    subjectID = @get("subjectID")
    if Ember.isEmpty(subjectID)
      return
    newActiveModel = null
    for responseObj in @get("model")
      if responseObj.subjectID == subjectID
        newActiveModel = responseObj
        break
    @set("activeModel", newActiveModel)
    form = @get("formStructure")
    if form.get("isManyToOne")
      @set("subjectID", subjectID)
      @notifyPropertyChange("secondaryIds")
      subjectID = @get("subjectID")
      @transitionToRoute("responses")
      Ember.run.next(=>
        @set("subjectID", subjectID)
      )
    else
      if @get("activeModel") == null
        @set("responseID", null)
      unless Ember.isEmpty(@get("activeModel.responses"))
        @set("responseID", @get("activeModel.responses")[0].responseID)
      @goToResponse()


  actions:
    selectSubject: ->
      if @get("tempSubjectID") == @get("subjectID") or Ember.isEmpty(@get("tempSubjectID").trim())
        @set("activeModel", null)
        return
      @set("subjectID", @get("tempSubjectID"))
      @set("secondaryID", null)
      @setSubjectID()


    selectSecondaryId: ->
      if @get("tempSecondaryID") == @get("secondaryID") or Ember.isEmpty(@get("tempSecondaryID").trim())
        return
      @set("secondaryID", @get("tempSecondaryID"))
      unless @get("activeModel") == null
        found = false
        for responseObj in @get("activeModel.responses")
          if responseObj.secondaryID == @get("secondaryID")
            found = true
            @set("responseID", responseObj.responseID)
            break
        if !found
          @set("responseID", null)
      @goToResponse()

    renameInstance: -> # update action in response.edit controller
      @send "openDialog", "rename_instance", @get("response").copy(), "renameInstance"

    deleteResponse: ->
      @send "openDialog", "delete_response", @get("response")








      #if Ember.isEmpty subjectID?.trim()
      #  @transitionToRoute "responses"
      #  return

      #route = if @get('canEnterData') then "instance.edit" else "instance"
      #@transitionToRoute(route, subjectID, -1)
      #$('#success-flash').addClass("hide")
      #@focusFirst()
