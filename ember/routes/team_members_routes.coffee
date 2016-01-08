LabCompass.TeamMembersIndexRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    @storage.loadTeamMembersIntoProject(@modelFor "project")

  resizePopup: ->
    document.getElementById(elementID).style.height = (window.innerHeight - 55) + "px"
    if $(".add-team-member").height() < heightOffset
      document.getElementById(elementID).style.overflowY = "auto"
    else 
      document.getElementById(elementID).style.overflowY = "hidden"     

  buildPopup: ->
    $(document).on 'opened', =>
      elementID = $(".add-team-member").attr("id")
      if elementID == "new-team-member-popup"  || elementID == "existing-team-member-popup"
        heightOffset = 608
        if elementID == "new-team-member-popup"
          heightOffset = 627
        document.getElementById(elementID).style.height = (window.innerHeight - 55) + "px"
        document.getElementsByTagName("body")[0].style.overflow = "hidden"
        if $(".add-team-member").height() < heightOffset
          document.getElementById(elementID).style.overflowY = "auto"
        else 
          document.getElementById(elementID).style.overflowY = "hidden" 

        $(window).on('resize', @resizePopup)


    $(document).on 'closed', =>
      document.getElementsByTagName("body")[0].style.overflow = "auto"
      $(window).off('resize', @resizePopup)

  killPopup: ->
    $(document).off 'opened'
    $(window).off('resize', @resizePopup)
    $(document).off 'closed'

  actions:
    willTransition: (trans) ->
      @_super()
      @killPopup()
      #if the team progress is not complete, reset the team button flag to false
      myModel = @modelFor("project")
      if myModel.get("isDemo") == true
        $("#myTeamJoyride").foundation('joyride','hide')
        Ember.run.next(=>
          if myModel.get("demoProgress.addTeamMemberProgress") == false
            myModel.set("demoProgress.teamButton", false)
            myModel.set("demoProgress.addNewTeamMember", false)
            @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
      )

    
    didTransition: ->
      @_super()
      @buildPopup()
      @controller.handleDemoProgress()
