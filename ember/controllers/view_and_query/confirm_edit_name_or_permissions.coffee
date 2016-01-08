LabCompass.ViewAndQueryConfirmEditNameOrPermissionsController = Ember.ObjectController.extend
  editModel: (->
    @get("model").copy()
  ).property "model"

  actions:
    confirmSaveQuery: ->
      queryController = @container.lookup("controller:view-and-query.query")
      @storage.saveQueryPermissions(@get("editModel"))
      .then (result) =>
        queryController.get("target").router.refresh()
        @send("closeDialog")