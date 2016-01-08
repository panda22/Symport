
LabCompass.RenameFormStructureController = Ember.ObjectController.extend LabCompass.WithProject,

  editModel: (->
    @get('model').copy()
  ).property 'model'

  needs: ['application']

  updateProperties: ["name"]

  actions:
    update: ->
      structure = @get "model"
      @storage.updateFormStructure(@get("project"), @get('editModel'), @get("newSecondaryId"))
      .then (res) =>
        structure.setProperties res.getProperties(@get("updateProperties"))
        #if @get('controllers.application.currentRouteName') == "project.form-data"
        if @get("model.fromFormData")
          @send("updateFormName", @get("model"))
        @send "closeDialog"
