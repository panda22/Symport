LabCompass.InstanceDeleteController = Ember.ObjectController.extend
  actions:
    confirmDeleteResponse: ->
      @send("confirmDeleteResponse")
      #      @send "closeDialog"
      #      response = @get "model"
      #      formStructure = response.get "formStructure"
      #      @storage.deleteFormResponse(formStructure, response).then =>
      #        @send "onSaveResponse"
      #        @transitionToRoute "responses"