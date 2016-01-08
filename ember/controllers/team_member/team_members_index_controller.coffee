LabCompass.TeamMembersIndexController = Ember.ObjectController.extend LabCompass.WithProject,

  breadCrumb: "Team"

  needs: 'application'

  teamReportObject: null

  reinviteUserLoading: false

  emptyTeam: (->
    @get('project.teamMembers.length') < 2
  ).property("model.teamMembers.length")

  currentUserIsAdmin: Ember.computed(->
    result = false
    for teamMember in @get("model.teamMembers.content")
      if teamMember.get("isCurrentUser")
        if teamMember.get("administrator")
          result = true
        break
    result
  )

  infoForTeamMember: (member)->
    info = member._data

    str = "\nFirst: " + info.firstName + "\nLast: " + info.lastName + "\nEmail: " + info.email + "\n"
  
    perm_str = ""
    perm_str = perm_str + "   Admin--" + info.administrator + "\n"
    perm_str = perm_str + "   PHI----" + info.viewPersonallyIdentifiableAnswers + "\n"
    perm_str = perm_str + "   Download Data--" + info.export + "\n"
    perm_str = perm_str + "   Create Forms---" + info.formCreation + "\n\n"

    form_str = "   Form Level Permissions:\n"
    for form in info.structurePermissions.content
      p = form._data
      if(info.administrator || p.permissionLevel == "Full")
        x = "Enter/Edit & Build"
      else 
        x = p.permissionLevel
      form_str = form_str + "     " + p.formStructureName + "---" + x + "\n"

    str = str + perm_str
    str = str + form_str + "____________________________________________________________________________________________\n"


    return str

  checkForPopupOpen: ->
    popup = $("#newUserInformation")
    myModel = @get('project')
    if popup.length > 0
      $($(".joyride-next-tip")[0]).trigger('click')
      $(".button.right.main").attr("disabled",true)
      $($(".personal-details-box .ember-text-field")[0]).val("steve@mntnlabs.com")
      $($(".personal-details-box .ember-text-field")[0]).attr("disabled", "disabled")
      $($(".joyride-next-tip")[3]).css("display", "none")

      $(window).on 'closed', =>
        $("#myTeamJoyride").foundation('joyride','hide')

      if myModel.get("demoProgress.addTeamMemberPersonalDetails") == false
        $($(".joyride-next-tip")[1]).on 'click', =>
          myModel.set("demoProgress.addTeamMemberPersonalDetails", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
          $($(".joyride-next-tip")[2]).on 'click', =>
            $(".button.right.main").attr("disabled",false)
            myModel.set("demoProgress.addTeamMemberProjectPermissions", true)
            @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
            $(".button.right.main").addClass("animated pulse infinite")
            $(".button.right.main").on 'click', =>
              myModel.set("demoProgress.addTeamMemberFormPermissions", true)
              @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
              $(".team-icon").css("border", "none")
              $(".team-icon").removeClass("animated pulse infinite")
              if myModel.get("demoProgress.displayHelpTooltip") == true
                Ember.run.later(=>
                  $("#helpJoyride").foundation("joyride", "off")
                  $("#helpJoyride").foundation("joyride", "start")
                  $(".joyride-close-tip").remove()
                  $($(".joyride-next-tip")[1]).on 'click', =>
                    @transitionToRoute "index"
                , 750)
      else if myModel.get("demoProgress.addTeamMemberProjectPermissions") == false
        $($(".joyride-next-tip")[1]).trigger('click')
        $($(".joyride-next-tip")[2]).on 'click', =>
          $(".button.right.main").attr("disabled",false)
          myModel.set("demoProgress.addTeamMemberProjectPermissions", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
          $(".button.right.main").addClass("animated pulse infinite")
          $(".button.right.main").on 'click', =>
            myModel.set("demoProgress.addTeamMemberFormPermissions", true)
            @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
            $(".team-icon").css("border", "none")
            $(".team-icon").removeClass("animated pulse infinite")
            if myModel.get("demoProgress.displayHelpTooltip") == true
              Ember.run.later(=>
                $("#helpJoyride").foundation("joyride", "off")
                $("#helpJoyride").foundation("joyride", "start")
                $(".joyride-close-tip").remove()
                $($(".joyride-next-tip")[1]).on 'click', =>
                  @transitionToRoute "index"
              , 750)
      else if myModel.get("demoProgress.addTeamMemberFormPermissions") == false
        $($(".joyride-next-tip")[1]).trigger('click')
        $($(".joyride-next-tip")[2]).trigger('click')
        $(".button.right.main").attr("disabled",false)
        $(".button.right.main").addClass("animated pulse infinite")
        $(".button.right.main").on 'click', =>
          myModel.set("demoProgress.addTeamMemberFormPermissions", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
          $(".team-icon").css("border", "none")
          $(".team-icon").removeClass("animated pulse infinite")
          if myModel.get("demoProgress.displayHelpTooltip") == true
            Ember.run.later(=>
              $("#helpJoyride").foundation("joyride", "off")
              $("#helpJoyride").foundation("joyride", "start")
              $(".joyride-close-tip").remove()
              $($(".joyride-next-tip")[1]).on 'click', =>
                @transitionToRoute "index"
            , 750)
    else
      window.setTimeout(=>
        @checkForPopupOpen()
      , 700)


  changeFormIcon: ->
    if @get('controllers.application.currentRouteName') == "project.index"
    else
      window.setTimeout(=>
        if $(".settings-icon").hasClass("active")
          $(".settings-icon").removeClass("active")
        else
          $(".settings-icon").addClass("active")
        @changeFormIcon()
      , 500)

  handleDemoProgress: ->
    myModel = @get('project')

    if (myModel.get("isDemo") == true && myModel.get("demoProgress.initialOnboarding") == false) || (myModel.get("isDemo") == true && myModel.get("demoProgress.initialOnboarding") == true && myModel.get("demoProgress.addTeamMemberProgress") == true)
      Ember.run.next(=>
        $("#addTeamMemberButton").attr("disabled", "disabled")
        $("#addTeamMemberButton").css("cursor", "not-allowed")
        $("#addTeamMemberButton").css("opacity", 0.5)
      )

    if myModel.get("isDemo") == true && myModel.get("demoProgress.initialOnboarding") == true && myModel.get("demoProgress.buildFormProgress") == false
      Ember.run.next(=>
        $(".settings-icon").addClass("animated pulse infinite")
        $(".settings-icon").css("box-shadow", "0px 0px 0px 3px #cccccc")
        @changeFormIcon()
        $(".settings-icon").on 'click', =>
          $(".settings-icon").removeClass("animated pulse infinite")
          $(".settings-icon").css("box-shadow", "none")
      )


    if myModel.get("isDemo") == true && myModel.get("demoProgress.initialOnboarding") == true && myModel.get("demoProgress.addTeamMemberProgress") == false
      Ember.run.next(=>
        $("#myTeamJoyride").foundation('joyride','off')
        $("#myTeamJoyride").foundation('joyride','start')
        $(".joyride-close-tip").remove()
        $($(".joyride-next-tip")[0]).css("visibility", "hidden")
        $("#addTeamMemberButton").on 'click', =>
          myModel.set("demoProgress.addNewTeamMember", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
          @checkForPopupOpen()
      )

  actions:
    downloadTeamMemberBreakdown: ->
      report = "PERMISSION BREAKDOWN for all team members in " + (@get 'project.name') + ":\n____________________________________________________________________________________________\n"
      for member in (@get 'project.teamMembers.content')
        report = report + @infoForTeamMember(member)
      data = new Blob([report], {type: 'text/plain'})
      if ((@get 'teamReportObject') != null)
        window.URL.revokeObjectURL(@get 'teamReportObject')
      @set 'teamReportObject', window.URL.createObjectURL(data)
      window.open ( @get 'teamReportObject' )

    addTeamMember: ->
      structurePermissions = @get('project.structures').map (structure) =>
        @storage.createModel "formStructurePermission",
          formStructureID: structure.get('id')
          formStructureName: structure.get('name')
          permissionLevel: "None"
      newMember = @storage.createModel "teamMember", structurePermissions: structurePermissions
      @send "openDialog", "add_new_team_member", newMember, "createTeamMember"

    reInviteUser: (teamMember) ->
      @set("reinviteUserLoading", true)
      email = teamMember.get("email")
      teamMemberID = null
      for teamMember in @get("model.teamMembers.content")
        if teamMember.get("isCurrentUser")
          teamMemberID = teamMember.id
          break
      @storage.getPendingUserFromTeamMember(email, teamMemberID)
      .then (pendingUserModel) =>
        @send "openDialog", "invite_new_user", pendingUserModel, "reInviteUserDialog"
        @set("reinviteUserLoading", false)
      , =>
        @set("reinviteUserLoading", false)

    confirmDeleteTeamMember: (teamMember) ->
      @send "openDialog", "confirm_delete_team_member", teamMember

    deleteTeamMember: (teamMember) ->
      @storage.deleteTeamMember(@get('model'), teamMember).then =>
        @send "closeDialog"

    editTeamMember: (teamMember) ->
      @send "openDialog", "edit_existing_team_member", teamMember, "updateTeamMember"

    viewTeamMember: (teamMember) ->
      @send "openDialog", "view_existing_team_member", teamMember, "updateTeamMember"
