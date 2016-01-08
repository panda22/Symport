LabCompass.ReInviteUserDialogController = Ember.ObjectController.extend LabCompass.WithProject,
  reInvite: true

  setButtonEnabledStatus: (status) ->
      $("button").each(->
        if status == false
          $(this).attr("disabled", true)
          $(this).addClass("disabled")
          if $(this).text() == "Send Invite"
            $(this).text("Loading...")
        else
          $(this).attr("disabled", false)
          $(this).removeClass("disabled")
          if $(this).text() == "Loading..."
            $(this).text("Send Invite")
    )

  actions:
    submit: ->
      @setButtonEnabledStatus(false)
      @storage.reInviteUser(@get("model"))
      .then (result) =>
        email = @get("model.email")
        for teamMember in @get("project.teamMembers.content")
          if teamMember.get("email") == email
            teamMember.setProperties
              firstName: @get("model.firstName")
              lastName: @get("model.lastName")
            break
        @setButtonEnabledStatus(true)
        @send "closeDialog"
      , (error) =>
        @setButtonEnabledStatus(true)