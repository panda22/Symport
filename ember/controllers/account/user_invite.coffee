LabCompass.AccountUserInviteController = Ember.ObjectController.extend
  
  eula: ""

  actions:
    signUp: ->
      if @get("eulaCheck") == true
        @storage.userInviteValidate(@get("model"))
        .then =>
          @transitionToRoute "index"
      else
        @set "errors.eula", "Please read our Terms of Service and Privacy Policy, then check the box below"

