LabCompass.ViewAndQueryConfirmDeleteQueryController = Ember.ObjectController.extend

  actions:
    confirmDeleteQuery: (query) ->
      @send "closeDialog"
      $("#" + query.id).fadeOut(1000, "linear")

      window.setTimeout =>
        savedQueryController = @container.lookup("controller:view-and-query.saved-queries")
        @storage.deleteQuery(query).then =>
          savedQueryController.removeObject(query)
      , 1000


