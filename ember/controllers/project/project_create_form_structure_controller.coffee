LabCompass.ProjectCreateFormStructureController = Ember.ObjectController.extend LabCompass.WithProject,
  changeDefaultSecondaryId: (->
    if @get("model.isManyToOne") == true
      @set("model.secondaryId", "Secondary ID")
    else
      @set("model.secondaryId", null)
  ).observes("model.isManyToOne")

  isSecondaryIdSettings: false
  checkSecondaryIdSettings: (->
    if @get("model.id")
      @set("isSecondaryIdSettings", true)
    else
       @set("isSecondaryIdSettings", false)
  ).observes("model.id")

  actions:
    create: ->
      structure = @get "model"
      keepForm = (structure.get("id") == null and structure.get("isManyToOne"))
      @storage.saveFormStructure(@get("project"), structure).then (result) =>
        if structure.get("isFromGrid")
          @send("addNewFormData", structure, keepForm)
        else
          unless keepForm
            @transitionToRoute 'form.build', result
            @send "closeDialog"
