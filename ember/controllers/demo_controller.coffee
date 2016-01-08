LabCompass.AccountDemoController = Ember.Controller.extend

  pendingTransition: null

  error: false
  email: null
  password: null
  attempts: 0
  wantsEnter: false

  doSignIn:(->
    if (@get 'wantsEnter')
      @send 'signIn'
  ).observes 'wantsEnter'

  
  actions:
    signIn: ->
      if (@get "attempts") >= 5
        return
      email = @get "email"
      password = @get "password"
      @storage.authorize email, password
      .then =>
        pendingTransition = @get "pendingTransition"
        @set "pendingTransition", null
        if pendingTransition
          pendingTransition.retry()
        else
          @transitionToRoute "index"
      , =>
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
