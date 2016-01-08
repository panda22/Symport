LabCompass.ProjectsIndexController = Ember.ArrayController.extend
  
  needs: 'application'
  compatibilityIssues: Ember.computed.alias 'controllers.application.compatibilityIssues'
  condensed_sidebar: Ember.computed.alias 'controllers.application.condensed_sidebar'
  lastViewedProject: Ember.computed.alias 'session.user.lastViewedProject'

  dontOpenProject: false

  listValue: "Recently Edited First"

  structureSorting: ["lastEdited:desc"]
  sortedProjects: Ember.computed.sort "model", 'structureSorting'
  listValue: "Recently Edited First"


  listValueObserver: (->
    val = @get('listValue')
    toPrint = @get("model")
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

  setJoyrideLocation: ->
    $(".joyride-tip-guide").css("width", "550px")
    joyrideHeight = $(".joyride-tip-guide").height()
    windowHeight = $(window).height()
    if windowHeight > joyrideHeight 
      diffHeight = windowHeight - joyrideHeight
      diffHeightString = diffHeight/2 + "px"
      diffHeightString2 = diffHeight/4 + "px"
      if $(".joyride-tip-guide").css("top") != diffHeightString2
        $(".joyride-tip-guide").css("top", diffHeight/4 + "px")
      else
        window.setTimeout(=>
          @setJoyrideLocation()
        , 100)
    $(window).on 'resize', =>
      if windowHeight > joyrideHeight 
        diffHeight = windowHeight - joyrideHeight
        diffHeightString = diffHeight/2 + "px"
        diffHeightString2 = diffHeight/4 + "px"
        if $(".joyride-tip-guide").css("top") != diffHeightString2
          $(".joyride-tip-guide").css("top", diffHeight/4 + "px")


  setNewProjText: ->
    if $(".project-name").length > 0
      $(".project-name").attr("value", "My First Project")
    else
      window.setTimeout(=>
        @setNewProjText()
      , 50)


  setEmptyState: ->
    if $(".no-projects-graphic") && @get("session.user.create") == false
      $("button.button.plus-with-text.left").addClass("animated pulse infinite")
      $("button.button.plus-with-text.left").on 'click', =>
        $("button.button.plus-with-text.left").removeClass("animated pulse infinite")
        @setNewProjText()

  doDemoStuff: ->
    myModel = @get('model')
    counter = 0
    while counter < myModel.length
      index_count = counter
      if myModel[index_count].get("isDemo") == true
        if myModel[index_count].get("demoProgress.projectIndexProgress") == false
          idNeeded = myModel[index_count].get("id")
          count_of_demoProject = index_count
          $("#" + idNeeded).addClass("animated pulse infinite")
          $("#" + idNeeded).on 'click', =>
            myModel[count_of_demoProject].set("demoProgress.projectIndexGlobal", true)
            myModel[count_of_demoProject].set("demoProgress.projectIndexDemoProject", true)
            @storage.updateDemoProgress(myModel[count_of_demoProject].get("id"), myModel[count_of_demoProject].get("demoProgress"))

          if myModel[index_count].get("demoProgress.projectIndexGlobal") == true
            $("#projectIndexJoyride").foundation('joyride', 'off')
            $("#projectIndexJoyride").foundation('joyride', 'start')
            $(".joyride-close-tip").remove()
            #@setJoyrideLocation()
            tips = $(".joyride-tip-guide")
            nextButtons = $(".joyride-next-tip")
            $(tips[0]).find(".joyride-next-tip").trigger('click')
            $(nextButtons[1]).on 'click', =>
              #@setJoyrideLocation()
              myModel[count_of_demoProject].set("demoProgress.projectIndexDemoProject", true)
              @storage.updateDemoProgress(myModel[count_of_demoProject].get("id"), myModel[count_of_demoProject].get("demoProgress"))
          else
            $("#projectIndexJoyride").foundation('joyride', 'off')
            $("#projectIndexJoyride").foundation('joyride', 'start')
            $(".joyride-close-tip").remove()
            #@setJoyrideLocation()            
            nextButtons = $(".joyride-next-tip")
            $(nextButtons[0]).on 'click', =>
              myModel[count_of_demoProject].set("demoProgress.projectIndexGlobal", true)
              @storage.updateDemoProgress(myModel[count_of_demoProject].get("id"), myModel[count_of_demoProject].get("demoProgress"))

            $(nextButtons[1]).on 'click', =>
              myModel[count_of_demoProject].set("demoProgress.projectIndexDemoProject", true)
              @storage.updateDemoProgress(myModel[count_of_demoProject].get("id"), myModel[count_of_demoProject].get("demoProgress"))
      counter++

    
     

  actions:
    createProject: ->
      @send "openDialog", "create_project", @storage.createModel("project")

    saveProject: (project) ->
      @storage.saveProject(project).then (res) =>
        @transitionToRoute 'project.form-data', res.id
        @storage.set('session.user.create', true)
        @send "closeDialog"

    confirmDeleteProject: (project) ->
      @set 'dontOpenProject', true
      @send "openDialog", "confirm_delete_project", project, "confirmDeleteProject"
      Ember.run.next =>
        @set "dontOpenProject", false

    deleteProject: (project) ->
      projectId = project.id
      @send "closeDialog"
      $("#" + projectId).fadeOut(1000, "linear")

      window.setTimeout =>
        @storage.deleteProject(project).then (res) =>
        @get('model').removeObject(project)
      , 1000

    editProjectSettings: (project) ->
      @set 'dontOpenProject', true
      @send "openDialog", "update_project", project, "updateProject"
      Ember.run.next =>
        @set "dontOpenProject", false
      
    openProject: (id) ->
      if @get('dontOpenProject')
        return
      @transitionToRoute "project.form-data", id
      @set 'lastViewedProject', id

    goToMntnlabs: ->
      window.open("http://mntnlabs.com")
