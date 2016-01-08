LabCompass.AccountSignUpController = Ember.ObjectController.extend

  c_id: ""
  eula: ""	
  betaPassword: ""



  actions:
    signUp: ->
      c_id = @get("c_id")
      captcha_response = grecaptcha.getResponse(c_id)
      #url = "https://www.google.com/recaptcha/api/siteverify?secret=6Lc7hQwTAAAAAOOgADXk9Gm-4Y6m-e6UlhQjGOOn&response="+grecaptcha.getResponse(c_id)

      if(@get("eulaCheck") == true) && (@get("betaPassword") == "Lab Compass")
        @set "errors.eula", ""
        @set "errors.betaPassword", ""
        grecaptcha.reset(c_id)
        @storage.createUser(@get("model"), captcha_response)
        .then =>
          Ember.run.next( ->
            $(".top-bar").css("position","fixed")
          )
          @transitionToRoute "index"
        , (error) =>
          @set "error", error
      else
        if @get("eulaCheck") != true
          @set "errors.eula", "Please read our Terms of Service and Privacy Policy, then check the box below"
        if (@get("betaPassword") != "Lab Compass")
          @set "errors.betaPassword", "Please contact a Symport representative to create an account."


