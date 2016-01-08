LabCompass.AccountProfileController = Ember.ObjectController.extend
  needs: 'application'
  condensed_sidebar: Ember.computed.alias 'controllers.application.condensed_sidebar'

  actions:
    save: ->
      @storage.saveUser @get "model"
      .then (user) =>
        @session.set "user", user
        @send "goBack"
    goBack: ->
      history = @session.history
      if history.length > 1
        prevPath = history[history.length - 2]
      else
        prevPath = "/projects"
      try
        @transitionToRoute(prevPath)
      catch
        try
          @transitionToRoute "projects.index"
        catch
          @transitionToRoute "account.sign-in"