LabCompass.AccountSignInController = Ember.Controller.extend
  needs: 'application'
  condensed_sidebar: Ember.computed.alias 'controllers.application.condensed_sidebar'

  pendingTransition: null

  error: false
  email: null
  password: null
  attempts: 0

  actions:
    signIn: ->
      if (@get "attempts") >= 5
        return
      email = @get("email").trim()
      password = @get "password"
      @storage.authorize email, password
      .then =>
        Ember.run.next( ->
          $(".top-bar").css("position","fixed")
        )
        @set("password", "")
        pendingTransition = @get "pendingTransition"
        @set "pendingTransition", null
        if pendingTransition
          pendingTransition.retry()
        else
          Ember.run.next =>
            path = @session.get 'user.lastViewedPage'
            if path != null && path != undefined
              @transitionToRoute path
            else
              @transitionToRoute "index"
      , =>
        @set("password", "")
        x = @get "attempts"
        x = x + 1
        @set "attempts", x
        if x >=5
          @set "error", "You have been locked out due to 5 failed login attempts. Please try again in 5 minutes" 
          setTimeout(=>
            @set "attempts", 0
            @set "error", false
          , 1000*60*5)
        else
          @set "error", "Incorrect email or password, please try again"
