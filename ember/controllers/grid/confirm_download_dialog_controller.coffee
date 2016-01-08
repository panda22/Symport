LabCompass.ConfirmDownloadDialogController = Ember.Controller.extend LabCompass.WithProject,

  canViewPhi: Ember.computed(->
    @storage.canViewProjectPhi(@get("project.id"))
  )

  downloadLink: (->
    "/project_view_data/download_results"
  ).property("model")

  additionalFields: Ember.A(["downloadOptions", "query"])

  downloadOptions:
    useCodes: false
    blockedCode: ""
    emptyCode: ""
    includePhi: false
    checkboxHorizontal: false

  allFormsSelected: true

  showSelectAll: (->
    formArray = @get("model.queriedForms")
    #should never have a length of 0 because then the 
    #empty state message will be shown
    if formArray.get("length") == 1 
      return false
    else
      return true
  ).property("model.queriedForms")

  getExportFormsString: ->
    exportForms = {}
    for formObj in @get("model.exportCheckBoxes")
      exportForms[formObj.formID] = formObj.get("checked")
    return exportForms

  addCheckBoxObservers: (->
    unless Ember.isEmpty(@get("model"))
      for form in @get("model.queriedForms.content")
        form.addObserver("included", @, @observeFormCheckBox)
    if @get("model.queriedForms.length")
      @observeFormCheckBox(@get("model.queriedForms.firstObject"))
  ).observes("model")

  observeFormCheckBox: (formObj) ->
    allIncluded = true
    includedCount = 0
    singleIncludedFormID = null
    for form in @get("model.queriedForms.content")
      if form.get("included")
        includedCount += 1
        singleIncludedFormID = form.get("formID")
      else
        allIncluded = false
    @set("allFormsSelected", allIncluded)
    if includedCount == 1
      @set("downloadLink", "/form_structures/#{singleIncludedFormID}/export")
      if @get("additionalFields.length") == 2
        @get("additionalFields").popObject()
        @set("additionalFields", @get("additionalFields"))
        @notifyPropertyChange("additionalFields")
    else
      if @get("additionalFields.length") == 1
        @get("additionalFields").pushObject("query")
        @set("additionalFields", @get("additionalFields"))
        @notifyPropertyChange("additionalFields")
      @set("downloadLink", "/project_view_data/download_results")

  actions:
    selectAllExportForms: (add) ->
      for form in @get("model.queriedForms.content")
        form.set("included", add)

    confirmExport: ->
      #for formObj in @get("model.exportCheckBoxes")
      #  formObj.set("checked", true)
      @send "closeDialog"