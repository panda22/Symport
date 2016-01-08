LabCompass.ViewAndQueryConfirmLeaveSavedQueryController = Ember.ObjectController.extend
  actions:
    confirmLeave: ->
      queryController = @container.lookup("controller:view-and-query.query")
      transition = queryController.get("storedTransition")
      queryController.set("parentModel", @get("model").copy())
      @set("model.isSaved", true)
      transition.retry()
      @send("closeDialog")