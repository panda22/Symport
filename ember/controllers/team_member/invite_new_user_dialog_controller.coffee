LabCompass.InviteNewUserDialogController = Ember.ObjectController.extend LabCompass.WithProject,
  reInvite: false

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
      @set("isError", false)
      @storage.inviteNewUser(@get("project"), @get("model"), @get("model.firstName"), @get("model.lastName"), @get("model.message"))
      .then((result) =>
        @send "closeDialog"
        @storage.set('session.user.invite', true)
        @setButtonEnabledStatus(true)
      , =>
        @setButtonEnabledStatus(true)
      )


