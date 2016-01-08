LabCompass.ProjectIndexController = Ember.ObjectController.extend LabCompass.WithProject, 

  needs: 'application'

  breadCrumb: "Forms"

  compatibilityIssues: Ember.computed.alias 'controllers.application.compatibilityIssues'
  structureSorting: ["lastEdited:desc"]
  sortedStructures: Ember.computed.sort "structures", 'structureSorting'
  listValue: "Recently Edited First"
  setModel: ->
    @set 'model', @get('project')

  listValueObserver: (->
      val = @get('listValue')
      if val == "A-Z"
        @set 'structureSorting', ["name"]
      else if val == "Z-A"
        @set 'structureSorting', ["name:desc"]
      else if val == "Recently Edited Last"
        @set 'structureSorting', ["lastEdited"]
      else
        @set 'structureSorting', ["lastEdited:desc"]
    ).observes "listValue"


  listSorting: ["A-Z", "Z-A", "Recently Edited First", "Recently Edited Last"]
  
  handleDemoStuff: ->
    demoProj = @get("demoProgress.demoFormId")
    Ember.run.next(=>
      if @get("isDemo") == true
        if @get("demoProgress.projectIndexProgress") == true
          if @get("demoProgress.formEnterEdit") == false
            $("#" + demoProj + " .small-5").attr("id", "formRide")
            $("#" + demoProj + " button.button.pencil-with-text").attr("id", "demoEnterEdit")
            $("#formsJoyride").foundation('joyride','off')
            $("#formsJoyride").foundation('joyride', 'start')
            $(".joyride-close-tip").remove()
            $(".joyride-next-tip").remove()
            $("#demoEnterEdit").addClass("animated pulse infinite")
            $("#demoEnterEdit").click(=>
              @set("demoProgress.formEnterEdit", true)
              @storage.updateDemoProgress(@get("id"), @get("demoProgress"))
              $("demoEnterEdit").removeClass("animated pulse infinite")
              $(".joyride-tip-guide").remove()
            )
    )

  changeTeamIcon: ->
    if @get("demoProgress.teamButton") == true || @get("isDemo") == false
      $(".team-icon").removeClass("active")
    else
      window.setTimeout(=>
        if $(".team-icon.teamText").hasClass("active")
          $(".team-icon").removeClass("active")
        else
          $(".team-icon").addClass("active")
        @changeTeamIcon()
      , 500)

  changeImportIcon: ->
    if @get("demoProgress.importButton") == true || @get("isDemo") == false
      $(".import-icon").removeClass("active")
    else
      window.setTimeout(=>
        if $(".import-icon").hasClass("active")
          $(".import-icon").removeClass("active")
        else
          $(".import-icon").addClass("active")
        @changeImportIcon()
      , 500)

  handleAdditionalDemoStuff: ->
    Ember.run.next(=>
      if @get("isDemo") == true && @get("demoProgress.initialOnboarding") == true && @get("demoProgress.additionalOnboarding") == false
        if @get("compatibilityIssues") == true
          @set("demoProgress.importButton", true)
          @set("demoProgress.importOverlays", true)
          @set("demoProgress.importCsvText", true)
        if @get("demoProgress.formGlobal") == true
          if @get("demoProgress.addTeamMemberProgress") == false
            @changeTeamIcon()
            $(".team-icon").addClass("animated pulse infinite")
            $(".team-icon").css("box-shadow", "0px 0px 0px 3px #cccccc")
            $(".team-icon").on 'click', =>
              $(".team-icon").removeClass("animated pulse infinite")
              $(".team-icon").css("box-shadow", "none")
              @set("demoProgress.teamButton", true)
              @storage.updateDemoProgress(@get("id"), @get("demoProgress"))
              
          if @get("demoProgress.importProgress") == false
            @changeImportIcon()
            $(".import-icon").addClass("animated pulse infinite")
            $(".import-icon").css("box-shadow", "0px 0px 0px 3px #cccccc")
            $(".import-icon").on 'click', =>
              $(".import-icon").removeClass("animated pulse infinite")
              $(".import-icon").css("box-shadow", "none")
              @set("demoProgress.importButton", true)
              @storage.updateDemoProgress(@get("id"), @get("demoProgress"))

          if @get("demoProgress.buildFormProgress") == false
            $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").addClass("animated pulse infinite")
            $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").on 'click', =>
              $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").removeClass("animated pulse infinite")
              $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").css("border", "1px solid #638cd3")
        else
          $("#additionalOnboardingGlobal").foundation('joyride','off')
          $("#additionalOnboardingGlobal").foundation('joyride','start')
          $(".joyride-close-tip").remove()
          $(".joyride-next-tip").on 'click', =>
            @set("demoProgress.formGlobal", true)
            @storage.updateDemoProgress(@get("id"), @get("demoProgress"))

            @changeTeamIcon()
            $(".team-icon").addClass("animated pulse infinite")
            $(".team-icon").css("box-shadow", "0px 0px 0px 3px #cccccc")
            $(".team-icon").on 'click', =>
              $(".team-icon").removeClass("animated pulse infinite")
              $(".team-icon").css("box-shadow", "none")
              @set("demoProgress.teamButton", true)
              @storage.updateDemoProgress(@get("id"), @get("demoProgress"))

            @changeImportIcon()
            $(".import-icon").addClass("animated pulse infinite")
            $(".import-icon").css("box-shadow", "0px 0px 0px 3px #cccccc")
            $(".import-icon").on 'click', =>
              $(".import-icon").removeClass("animated pulse infinite")
              $(".import-icon").css("box-shadow", "none")
              @set("demoProgress.importButton", true)
              @storage.updateDemoProgress(@get("id"), @get("demoProgress"))

            $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").addClass("animated pulse infinite")
            $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").on 'click', =>
              $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").removeClass("animated pulse infinite")
              $("#"+@get("demoProgress.demoFormId") + " .button.hammer-with-text").css("border", "1px solid #638cd3")
    )

  handleSidebarTopbar: ->
    $('li[tooltip="Forms"]').css("color","#82bbe6")
    $('li[tooltip="Team"]').css("color","#cccccc")
    $('li[tooltip="Import"]').css("color","#cccccc")
    $('li[tooltip="Data"]').css("color","#cccccc")
    Ember.run.next(=>
      try
        $(document).foundation()
      if $("#titleArea").hasClass("condensed-sidebar")
        $("#sidebar-id").attr("class", "left-column condensed-sidebar-left ")    
        $("#page-content").attr("class", "right-column condensed-sidebar-right")
        @set "controller.condensed_sidebar", true
        $("#barText").addClass("condensed-sidebar")
      $('.top-bar').css("z-index", 1)
      $('.my-projects-header-box').css("box-shadow", "none")
      $("#titleArea").css("box-shadow", "-17px -22px 10px 21px #cccccc")
    )


  actions:
    addFormStructure: ->
      formStructure = @storage.createNewFormStructure()
      formStructure.set("isNewForm", true)
      @send "openDialog", "create_form_structure", formStructure, "projectCreateFormStructure"

    manageTeam: ->
      @transitionToRoute "team-members.index", @get("model")








    #goToGrid: ->
      #@transitionToRoute "view-and-query.grid"


    # replaceFormStructure: (original, updated) ->
    #   debugger
    #   structs = @get('model.form_structures')
    #   idx = structs.indexOf(original)
    #   structs.replace(idx, 1, updated)
    #
