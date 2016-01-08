LabCompass.UpdateTeamMemberController = Ember.ObjectController.extend LabCompass.WithProject,

  editModel: (->
    @get('model').copy()
  ).property 'model'

  updateProperties: ["expirationDate", "administrator", "export", "auditLog", "formCreation", "viewPersonallyIdentifiableAnswers", "structurePermissions"]

  actions:
    update: ->
      teamMember = @get "model"
      @storage.updateTeamMember(@get("project"), @get('editModel')).then (res) =>
        teamMember.setProperties res.getProperties(@get("updateProperties"))
        $(".button.right.main.big-dialog").addClass("disabled")
        $(".button.cancel.big-dialog").addClass("disabled")
        $(".button.right.main.big-dialog").text("Loading...")
        $(".button.right.main.big-dialog").attr("disabled", true)
        $(".button.cancel.big-dialog").attr("disabled", true)
        @send "closeDialog"
