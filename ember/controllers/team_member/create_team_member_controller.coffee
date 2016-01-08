LabCompass.CreateTeamMemberController = Ember.ObjectController.extend LabCompass.WithProject,

  editModel: (->
    @get('model')
  ).property 'model'

  actions:
    createNewTeamMember: ->
      $(".button.right.main.big-dialog").addClass("disabled")
      $(".button.cancel.big-dialog").addClass("disabled")
      $(".button.right.main.big-dialog").text("Loading...")
      $(".button.right.main.big-dialog").attr("disabled", true)
      $(".button.cancel.big-dialog").attr("disabled", true)

      @storage.createNewTeamMember(@get("project"), @get('editModel')).then(=>
        @send "closeDialog"
        @storage.set('session.user.invite', true)
      , (canCreateNewUser) =>
        if canCreateNewUser == true
          @send "closeDialog"
          @set("editModel.firstName", "")
          @set("editModel.lastName", "")
          @set("editModel.message", "Welcome to Symport")
          @send "openDialog", "invite_new_user", @get("editModel"), "inviteNewUserDialog"
      ,

        Ember.run.next(->
          $(".button.right.main.big-dialog").removeClass("disabled")
          $(".button.cancel.big-dialog").removeClass("disabled")
          $(".button.right.main.big-dialog").text("Add Team Member")
          $(".button.right.main.big-dialog").attr("disabled", false)
          $(".button.cancel.big-dialog").attr("disabled", false)
        )
      )