LabCompass.ProtectedRoute = Ember.Route.extend

  beforeProtectedModel: (transition) ->

  beforeModel: (transition) ->
    @set("pageUrl", window.location.href)
    if !@session.get("isAuthenticated")
      if @session.get("user") != null
        @revalidateSession transition
      else
        @redirectToSignIn transition
    else @beforeProtectedModel arguments...

  redirectToSignIn: (transition) ->
    #need to redifine to redirect to a page/bring up modal to ask for password again
    transition.abort()
    @session.stopTitle()
    signInController = @controllerFor "account.sign-in"
    signInController.set "pendingTransition", transition
    @transitionTo "account.sign-in"

  revalidateSession: (transition) ->
    transition.abort()
    @session.stopTitle()
    @transitionTo "account.revalidate-session"

  changeDataIcon: ->
    myModel = @modelFor('project')
    if myModel.get("demoProgress.dataTabEmphasis") == true
    else
      window.setTimeout(=>
        if $(".view-data-icon.dataText").hasClass("active")
          $(".view-data-icon.dataText").removeClass("active")
        else
          $(".view-data-icon.dataText").addClass("active")
        @changeDataIcon()
      , 500)

  actions: 
    willTransition: ->
      @send "destroyTooltips"
      Ember.run.next(->
        $(".tabs").css("margin-top", "19px")
      )

    didTransition: ->
      @send "destroyOpenTooltips"
      Ember.run.next(=>
        try
          $(document).foundation()
        textForPage = $(".header-box h2").text()
        $("#barText").text(textForPage)
        $(".top-bar").css("position","fixed")
        $('.top-bar').css("z-index", 1)
        $('.my-projects-header-box').css("box-shadow", "none")
        $("#titleArea").css("box-shadow", "-17px -22px 10px 21px #cccccc")
        if $(".breadcrumbs").height() > 18
          $(".tabs").css("margin-top", "1px")
        else
          $(".tabs").css("margin-top", "19px")

        #myModel = @modelFor("project")
        #if myModel.get("isDemo") == true
        #  if myModel.get("demoProgress.enterEditSave") == true && myModel.get("demoProgress.dataTabEmphasis") == false
        #    $(".view-data-icon").addClass("animated pulse infinite")
        #    @changeDataIcon()
        #    $(".view-data-icon").css("box-shadow", "0px 0px 0px 3px #82bbe6")
        #    $(".view-data-icon").on 'click', =>
        #      $(".view-data-icon").removeClass("animated pulse infinite")
        #      $(".view-data-icon").css("box-shadow", "none")
        #      myModel.set("demoProgress.dataTabEmphasis", true)
        #      @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))

        MAX_HISTORY_LENGTH = 20
        path = @get("router.url")
        user = @get 'session.user'
        user.set 'lastViewedPage', path
        @storage.saveUserLastVisited(user)
        history = @session.get("history")
        if history.length == 0 or history[history.length - 1] != path
          history.pushObject(path)
        if history.length > MAX_HISTORY_LENGTH
          @session.set("history", history.slice(history.length - MAX_HISTORY_LENGTH))
        $(window).scrollTop(0)

      )

