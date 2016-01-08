LabCompass.DownloadFormResponsesController = Ember.ObjectController.extend

  downloadLink: (->
    "/form_structures/" + (@get('model.id')) + "/export"
  ).property 'model'

  shortName: Ember.computed(->
    @get("model.shortName")
  )

  projectShortName: Ember.computed(->
    @get("model.projectShortName")
  )

  formShortName: Ember.computed (->
    @get("model.formShortName")
  )

  additionalDownloadFields: ["downloadOptions"]

  canViewPhi: Ember.computed(->
    @get("model.userPermissions.viewPhiData")
  )

  downloadOptions: {
    includePhi: false
    useCodes: false
    emptyAnswerCode: ""
    conditionallyBlockedCode: ""
    checkboxHorizontal: false
  }

  actions:
    dataDownloaded: ->
      @send "closeDialog"
