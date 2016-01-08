LabCompass.ProjectsCreateRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    @storage.createNewProject()

LabCompass.ProjectRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    @storage.loadProject(params.projectID)
    .then (result) =>
      result

  serialize: (model) ->
    projectID: model.get('id')


LabCompass.ProjectIndexRoute = LabCompass.ProtectedRoute.extend
  refreshing: false

  model: ->
    @storage.loadProject(this.modelFor("project").id)
    .then (result) =>
      result

  serialize: (model) ->
    projectID: model.get('id')

  actions:
    didTransition: ->
      @_super()
      Ember.run.next (=>
        try
          $(document).foundation()
        @controller.handleSidebarTopbar()
      )
      if @get("refreshing")
        @controller.handleDemoStuff()
        @controller.handleAdditionalDemoStuff()
        @set "refreshing", false
      else
        @set "refreshing", true
        @refresh()


    willTransition: ->
      $("#formsJoyride").foundation('joyride', 'hide')
      $("#additionalOnboardingGlobal").foundation('joyride','hide')
      if @get("refreshing") == false
        @_super()
        if @get("controller.demoProgress.formEnterEdit") == true
          myModel = @modelFor "project"
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))


LabCompass.ProjectsIndexRoute = LabCompass.ProtectedRoute.extend

  init: ->
    if @controllerFor('application').get('compatibilityIssues')
      Ember.run.next(=>
        @send "openDialog", "compatibility"
      )

  model: (params) ->
    @storage.loadAllProjects()

  positionProjectSettings: ->
    innerCards = $(".clickable-project-container")
    counter = 0
    while counter != innerCards.length
      if $(innerCards[counter]).height() > 97
        difference = ($(innerCards[counter]).height()-97)/2
        difference = difference + 35
        $(innerCards[counter]).find('.project-links').css("margin-top", difference + "px")
      else
        $(innerCards[counter]).find('.project-links').css("margin-top",  "35px")
      counter++

  actions:
    didTransition: ->
      @_super()
      Ember.run.next (=>
        $(".top-bar").css("position","fixed")
        $(".top-bar").css("z-index",2)
        $(".top-bar").css("box-shadow","none")
        $("#barText").text("My Projects")
        $("#barText").addClass("card-title")
        $("#titleArea").css("box-shadow", "none")
        if $("#titleArea").hasClass("condensed-sidebar")
          $("#titleArea").removeClass("condensed-sidebar")
          @set "controller.condensed_sidebar", false
          $("#barText").removeClass("condensed-sidebar")
        @controller.setEmptyState()
        @controller.doDemoStuff()
        @positionProjectSettings()
        $(window).on('resize', @positionProjectSettings)
      )

    willTransition: ->
      Ember.run.next (->
        $("#barText").text("")
        $("#barText").removeClass("card-title")
        $(window).off('resize', @positionProjectSettings)
      )

LabCompass.ProjectsOverlaysRoute = LabCompass.ProtectedRoute.extend
  resizeOverlays: ->
    ele = document.getElementById('image')
    ele.style.height = (0.57 * ele.offsetWidth) + "px" 

  model: ->
    @storage.loadUser()

  actions:
    didTransition: ->
      @_super()
      @set 'controller.dontChangeImage', false
      
      window.setTimeout(->
        try
          ele = document.getElementById('image')
          ele.style.height = (0.57 * ele.offsetWidth) + "px"
        catch
          window.setTimeout(->
            ele = document.getElementById('image')
            ele.style.height = (0.57 * ele.offsetWidth) + "px"
          , 200)
      , 200)

      $(window).on('resize', @resizeOverlays)


    willTransition: ->
      @_super()
      $(window).off('resize', @resizeOverlays)


LabCompass.ProjectImportRoute = LabCompass.ProtectedRoute.extend
  
  afterModel: (resolvedModel, transition)->
    @controllerFor('project.import').set('form_from_trans', transition.queryParams.form_from_trans)

  actions:
    didTransition: ->
      @_super()
      c = @get "controller"
      c.handleResize(true)

    willTransition: (trans)->
      @_super()
      c = @get "controller"
      if @controller.handleTransition(trans)
        c.handleResize(false)
        if trans.targetName != "account.revalidate-session"
          c.resetProperties()

LabCompass.ProjectFormDataRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    formID = null
    unless Ember.isEmpty(params.queryParams.formID)
      formID = params.queryParams.formID
    project = @container.lookup("controller:project").get("model")
    if Ember.isEmpty(project)
      project = @modelFor("project")
    @storage.constructFormDataArray(project, formID)


  setupController: (controller, model) ->
    controller.setProperties({
      model: model,
      projectID: @modelFor("project").id,
      numFormsLoaded: 0,
      allFormsLoaded: false
    })
    if model.get("length") > 0
      activeModel = controller.get("content")[0]
      for formData in model
        if formData.get("isInitActive")
          activeModel = formData
          break
      controller.set("activeModel", activeModel)
      controller.loadData(activeModel.get("formID"), true)
      for formData in controller.get("content")
        unless formData == activeModel
          controller.loadData(formData.get("formID"), false)
    else
      controller.setProperties({
        model: []
        activeModel: null
      })

  actions:
    didTransition: ->
      @_super()
      @controller.setWindowEvents()
      #check that user is ready for onboarding popup
      #fire popup after checking if statement
      if (@get("session.user.create") == false) || (@get("session.user.import") == false)
        Ember.run.next(=>
          @send "openDialog", "onboarding", @get("model"), "onboardingDialog"
        )

    willTransition: ->
      @_super()
      @controller.unsetWindowEvents()







