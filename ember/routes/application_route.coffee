LabCompass.ApplicationRoute = Ember.Route.extend

  dialogClosed: null
  currentDialog: null
  displayingdDialog: false

  backToIndexOnError: (errorMessage) ->
    if errorMessage == "You do not have access to enter responses for this form"
      return
    if @get('currentDialog')
      @send "closeDialog"
    if @router.router.currentHandlerInfos # YUCK FIXME check for if we are ready to handle sends
      errorMessage ||= "Something went wrong."
      @send "openDialog", "error", Ember.Object.create(message: errorMessage), "error"
    else
      @container.lookup("router:main").transitionTo "projects.index"

  _close: ->
    if @get("displayingDialog")
      @send "destroyOpenTooltips"
      dialog = @get "currentDialog"
      try
        dialog.foundation "reveal", "close"
      @get "dialogClosed"
    else
      Ember.RSVP.resolve()

  _open: (templateName, content, controllerName, target) ->
    @send "destroyOpenTooltips"
    @_close().then =>
      @set "displayingDialog", true

      if content
        if !controllerName
          controllerName = "dialog"
        if !target
          target = @controllerFor(@get("controller.currentRouteName"))
        @controllerFor(controllerName).set "target", target
        @controllerFor(controllerName).set "model", content
      controllerName ||= @get "controller.currentRouteName"

      @render "dialogs/#{templateName}",
        into: "application"
        outlet: "dialog"
        controller: controllerName

      # The template will not be rendered until the end of this runloop invocation.
      # Wait until then to actually trigger the open.
      Ember.run.next @, ->
        @set "dialogClosed", Ember.Deferred.create()
        dialogDiv = $("#appDialog > div")
        if !dialogDiv.attr("data-reveal")
          dialogDiv.attr "data-reveal", ""
        try
          dialogDiv.foundation()
          @set "currentDialog", dialogDiv
          dialogDiv.foundation("reveal", "open").one "closed", =>
            @disconnectOutlet
              parentView: "application"
              outlet: "dialog"
            @set "displayingDialog", false
            @set "currentDialog", null
            @get("dialogClosed").resolve()


  actions:
    # Both content and controllerName are optional if you wish to render the
    # currently active model into the currently active controller
    openDialog: (templateName, content, controllerName, target)->
      @_open arguments...

    closeDialog: ->
      @_close()

    loadingOn: (waitingText="Loading")->
      $(".loadingContainer .table-header").text(waitingText)
      $(".loadingContainer").css("visibility","visible")

    loadingOff: ->
      $(".loadingContainer").css("visibility","hidden")

    goToChromeDownload: ->
      window.open("https://www.google.com/chrome/browser/desktop/")

    # Override and call super in routes where saving is actually necessary.
    saveAndExit: ->
      @transitionTo 'session.destroy'

    destroyOpenTooltips: ->
      Ember.run.next ->
        for tooltip in $("span.tooltip")
          display = tooltip.style["display"]
          if display != "none" && display != ""
            $(tooltip).remove()

    destroyTooltips:(onlyOpen) ->
      for tooltip in $("span.tooltip")
        $(tooltip).remove()

    handleTopBar: ->
      $(".top-bar").css("position, fixed")