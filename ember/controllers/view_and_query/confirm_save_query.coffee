LabCompass.ViewAndQueryConfirmSaveQueryController = Ember.ObjectController.extend
  isNewQuery: false

  setIsNewQuery: (->
    @set("isNewQuery", @get("model.id") == null)
  ).observes "model"

  actions:
    confirmSaveQuery: ->
      queryController = @container.lookup("controller:view-and-query.query")
      @storage.saveQuery(@get("model"))
      .then (result) =>
        queryController.set("isSaved", true)
        @set("model.isSaved", true)
        queryController.set("parentModel", queryController.get("model").copy())
        $("button.button.main").removeClass(".right")
        @send "closeDialog"