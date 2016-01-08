LabCompass.OnboardingDialogController = Ember.ObjectController.extend
  needs: ['application', 'project']

  pID: Ember.computed.alias 'controllers.project.projectID'

  actions:
    sampleOutcome: ->
      @send "closeDialog"
      myModel = @get("controllers.project")
      @storage.importSampleData1(myModel.get("id")).then =>
        location.reload()
      #refresh page
      @set("session.user.create", true)
      @set("session.user.import", true)
    sampleVisit: ->
      @send "closeDialog"
      myModel = @get("controllers.project")
      @storage.importSampleData2(myModel.get("id")).then =>
        location.reload()
      #refresh page
      @set("session.user.create", true)
      @set("session.user.import", true)
    importOwnDb: ->
      @send "closeDialog"
      @set("session.user.create", true)
      @send "import", @get("activeModel.formStructure")

    manualBuild: ->
      @send "closeDialog"