LabCompass.ResponseEditController = LabCompass.ResponseViewController.extend

  needs: ["response", "project", 'responses', 'form', 'application']
  #parentModel: Ember.computed.alias "controllers.response.model"
  parentModel: (->
    @get("model.copy")
  ).property "model"
  subjectID: Ember.computed.alias "controllers.responses.subjectID"
  project: Ember.computed.alias "controllers.project.model"
  onMobile: Ember.computed.alias "controllers.application.onMobile"

  canRenameSubjectIDs: Ember.computed.alias "project.userPermissions.renameSubjectIDs"

  isManyToOne: Ember.computed.alias "model.formStructure.isManyToOne"

  isDisplayed: Ember.computed.alias "controllers.response.isDisplayed"

  shortSecondary: (->
    secondaryIdentification = @get "model.formStructure.secondaryId"
    if secondaryIdentification.length > 14
      secondaryIdentification = secondaryIdentification.substring(0,10)
      secondaryIdentification = secondaryIdentification + "..."
    return secondaryIdentification
  ).property "model.formStructure.secondaryId"

  enabled: true

  canCreateInstance: Ember.computed.alias "model.formStructure.userPermissions.enterData"


  canJumpToOtherForm: ( ->
    @get("otherForms.length") > 0
  ).property "otherForms.length"

  focusFirstAfterTrans: false
  focusFirst: =>
    window.setTimeout(=>
      try
        document.getElementsByClassName("edit-answer-field")[0].focus()
      catch
        window.setTimeout(=>
          try
            document.getElementsByClassName("edit-answer-field")[0].focus()
          catch
        , 200)
    , 200)


  showSaving: false
  showSuccess: false
  savingID: null

  save: ->
    @set('showSaving', true)
    $(".saveSlider")[0].style.height = 50 + "px"
    $('#success-flash').addClass("hide")
    $('.error-notification').addClass("hide")
    #if(@get 'model.newSubject')
    #  @set 'subjectID', ''
    @storage.saveFormResponse(@get 'model').then ((updatedResponse) =>
      #newSubject = (@get 'model.newSubject')
      @set("isErrors", false)
      #@set "model.newSubject", false # update this model as well TODO copy all answers?
      @set "parentModel", updatedResponse.response
      #@set("model.allInstances", updatedResponse.response.allInstances)
      #if @get("model.id") == null
      #  @set("model.id", updatedResponse.response.id)
      #@set "model", updatedResponse.response
      @get('project.structures').forEach (form) =>
        if form.get('id') == @get('model.formStructure.id')
          form.set('responsesCount', updatedResponse.numEntries)
      @showSuccessFlash()
      #if newSubject
      #  @send "onSaveResponse"
      #  window.setTimeout(=>
      #    @set 'subjectID', @get('model.subjectID')
      #  , 75)
    ), =>
      #if (@get 'model.newSubject')
      #  @send "onSaveResponse"
      #  window.setTimeout(=>
      #    @set 'subjectID', @get('model.subjectID')
      #  , 75)
      @set("parentModel", @get("model").copy())
      @setAnswerErrors()

  showSuccessFlash: ->
    @set('showSaving', false)
    Ember.run.next ->
      $('#success-flash').removeClass("hide")
      if $("#success-flash").outerHeight() > 50 && !$("#success-flash").hasClass("success hide")
        $(".saveSlider")[0].style.height = $("#success-flash").outerHeight() + 7 +  "px"
    
    
  hasChanges: ->
    editModel = @get('model')
    unless editModel
      return false
    originalModel = @get('parentModel')
    editAnswers = editModel.get('sortedAnswers').mapBy('answer')
    originalAnswers = originalModel.get('sortedAnswers').mapBy('answer')
    result = Ember.compare(editAnswers, originalAnswers) != 0
    return result

  handleTransition: (trans) ->
    if trans.targetName != "account.revalidate-session" && @hasChanges()
      trans.abort()
      @set('restoreTransition', trans)
      @send "openDialog", "confirm_leave_entry", @get("model")
      false
    else
      true

  answerErrors: []
  greaterThanOneError: false
  isErrors: false

  setAnswerErrors: ->
    @set('showSaving', false)
    $('.error-notification').removeClass("hide")
    @set("isErrors", true)
    retErrors = []
    answers = @get("model.sortedAnswers")
    i = 1
    for answer in answers
      error = answer.get("errors.content.answer")
      if error.length > 0
        retErrors.push({
          questionNumber: answer.get("question.questionNumber")
          displayNumber: answer.get('question.sequenceNumber')
          appendString: ", "
          })
      i++
    if retErrors.length > 0
      retErrors[retErrors.length - 1]["appendString"] = ""
    if retErrors.length > 1
      @set("greaterThanOneError", true)
    else
      @set("greaterThanOneError", false)
    @set("answerErrors", retErrors)
    if $(".error-notification").outerHeight() > 50 && $(".error-notification").hasClass("show")
      $(".saveSlider")[0].style.height = $(".error-notification").outerHeight() + 7 + "px"

  updateHeadingColors: ->
    for answer in @get("model.sortedAnswers")
      domObj = $("#" + answer.get("question.questionNumber")).parent()
      domObj.removeClass("error-heading no-error-heading")
      
      if answer.get("errors.answer")
        domObj.addClass("filled-in-heading error-heading")
      else
        if answer.get("answer") == ""
          domObj.addClass("empty-saved-heading no-error-heading")
        else
          domObj.addClass("filled-in-heading no-error-heading")

  onNewSubject: (->
     $('#success-flash').addClass("hide")
  ).observes 'model.subjectID'


  changeDataIcon: ->
    myModel = @get('project')
    if myModel.get("demoProgress.dataTabEmphasis") == true
    else
      window.setTimeout(=>
        if $(".view-data-icon.dataText").hasClass("active")
          $(".view-data-icon.dataText").removeClass("active")
        else
          $(".view-data-icon.dataText").addClass("active")
        @changeDataIcon()
      , 500)

  handleDemoStuff: ->    
    myModel = @get('project')
    myForm = @get('formStructure')
    tips = $(".joyride-tip-guide")
    if myModel.get("demoProgress.demoFormId") == myForm.get("id")
      if myModel.get("demoProgress.enterEditProgress") == false
        if myModel.get("demoProgress.formEnterEdit") == true
          if myModel.get("demoProgress.enterEditResponse") == false
            $(tips[0]).find(".joyride-next-tip").trigger('click')
            $(tips[1]).find(".joyride-next-tip").on 'click', =>
              myModel.set("demoProgress.enterEditResponse", true)
              @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
              nextButtons = $(".joyride-next-tip")
              $(nextButtons[2]).css("display", "none")
              topVal = $(tips[2]).css("top")
              topVal = topVal.substring(0, topVal.length-2)
              topVal = Number(topVal)
              topVal = topVal + 47
              $(tips[2]).css("top", topVal + "px")
              $("#savingButton").addClass("animated pulse infinite")
              $("#savingButton").css("box-shadow", "#00a99c")
              $("#savingButton").on 'click', =>
                myModel.set("demoProgress.enterEditSave", true)
                @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
                $(tips[2]).find(".joyride-next-tip").trigger('click')
                $("#savingButton").removeClass("animated pulse infinite")
                $("#savingButton").css("box-shadow", "none")
                $(".view-data-icon").addClass("animated pulse infinite")
                @changeDataIcon()
                $(".view-data-icon").css("box-shadow", "0px 0px 0px 3px #82bbe6")
                $(".view-data-icon").on 'click', =>
                  $(".view-data-icon").removeClass("animated pulse infinite")
                  $(".view-data-icon").css("box-shadow", "none")
                  myModel.set("demoProgress.dataTabEmphasis", true)
                  @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))       
          else
            $(tips[0]).find(".joyride-next-tip").trigger('click')
            $(tips[1]).css("visibility", "hidden")
            $(tips[1]).find(".joyride-next-tip").on 'click', =>
              myModel.set("demoProgress.enterEditResponse", true)
              #@storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
              nextButtons = $(".joyride-next-tip")
              $(nextButtons[2]).css("display", "none")
              topVal = $(tips[2]).css("top")
              topVal = topVal.substring(0, topVal.length-2)
              topVal = Number(topVal)
              topVal = topVal + 47
              $(tips[2]).css("top", topVal + "px")
              $("#savingButton").addClass("animated pulse infinite")
              $("#savingButton").css("box-shadow", "#00a99c")
              $("#savingButton").on 'click', =>
                myModel.set("demoProgress.enterEditSave", true)
                @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
                $(tips[2]).find(".joyride-next-tip").trigger('click')
                $("#savingButton").removeClass("animated pulse infinite")
                $("#savingButton").css("box-shadow", "none")
                $(".view-data-icon").addClass("animated pulse infinite")
                @changeDataIcon()
                $(".view-data-icon").css("box-shadow", "0px 0px 0px 3px #82bbe6")
                $(".view-data-icon").on 'click', =>
                  $(".view-data-icon").removeClass("animated pulse infinite")
                  $(".view-data-icon").css("box-shadow", "none")
                  myModel.set("demoProgress.dataTabEmphasis", true)
                  @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))           
            $(tips[1]).find(".joyride-next-tip").trigger('click')
      else
        $(".joyride-tip-guide").remove()

  clearSubject: ->
    responses = @get("controllers.responses")
    responses.set("subjectID", "")
    responses.set("activeModel", null)
    @send("onSaveResponse")
    @transitionToRoute "responses"


  actions:
    saveResponse: ->
      $(".viewingText").css("visibility", "hidden")
      @save().then(=>
        @updateHeadingColors()
        @set("isErrors", false)
      => 
        @updateHeadingColors()
      )

    confirmLeave: ->
      @send "closeDialog"
      @set("isErrors", false)
      trans = @get('restoreTransition')
      @set('model', null)
      trans.retry()
      wantsFocus = @get 'focusFirstAfterTrans'
      @set 'focusFirstAfterTrans', false
      if wantsFocus
        @focusFirst()

    editSubjectID: ->
      if @hasChanges()
        @send "openDialog", "save_before_manage_subject"
      else
        copy = @get('model').copy()
        copy.set "old_id", copy.get('subjectID')
        @send "openDialog", "update_subject_id", copy

    updateSubjectID: (updatedResponse) ->
      project = @get "project"
      oldSubjectID = updatedResponse.get "old_id"
      newSubjectID = updatedResponse.get "subjectID"
      @storage.renameSubjectID(project, oldSubjectID, newSubjectID).then(=>
        @send("closeDialog")
        @get("target").router.refresh()
      )

    goToError:  (errorNum, error)->
      errorPage = Math.floor((errorNum - 1) / @QUESTIONS_PER_PAGE)
      if @get("curPage") != errorPage
        @setupDisplayedQuestions(errorPage)
      Ember.run.next( =>
        targetDiv = $("#" + errorNum)
        $('html, body').animate({
          scrollTop: targetDiv.offset().top - ($(window).height() / 2)
        }, 300)
        @setAnswerErrors()
      )

    confirmDeleteResponse: ->
      @send "closeDialog"
      response = @get "model"
      formStructure = response.get "formStructure"
      @storage.deleteFormResponse(formStructure, response).then =>
        @clearSubject()

    deleteAllInstancesForSubject: ->
      @send "openDialog", "delete_instances", @get("model")

    confirmDeleteInstances: ->
      @send "closeDialog"
      @storage.destroyInstancesForSubject(@get("model.formStructure.id"), @get("model.subjectID"))
      .then =>
        @clearSubject()

    updateSecondaryId: (newResponse)->
      @get("target").router.refresh()






    

