LabCompass.UpdateProjectController = Ember.ObjectController.extend

  editModel: (->
    @get('model').copy()
  ).property 'model'


  actions:
    updateProjectName: ->
      structure = @get "model"
      @storage.saveProject(@get("editModel")).then (updatedFromServerProject) =>
        structure.setProperties updatedFromServerProject.serialize()
        @send "closeDialog"