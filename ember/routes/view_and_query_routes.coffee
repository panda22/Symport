LabCompass.ViewAndQueryViewRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    @storage.createModel "projectGrid"

  afterModel: (curmodel, transition) ->
    projectID = transition.params.project.projectID
    curmodel.projectID = projectID
    curmodel.loadData(transition.params.project.projectID, @storage)
    curmodel.set("activePage.query", false)
    curmodel.set("activePage.grid", true)

  viewQueryDemoStuff: ->
    portion = $("#searchingPortion")
    if portion.length > 0
      @controller.handleDemoStuff()
    else
      window.setTimeout(=>
        @viewQueryDemoStuff()
      , 100)

  actions:
    willTransition: (transition) ->
      @_super()
      $(".import-icon").removeClass("active")
      if @controller.get("isLoaded") == false
        transition.abort()
      @get("controller").resetController()
      @controller.set("model.activePage.grid", false)
      @controller.set("model.activePage.grid", false)
      $("#searchSortJoyride").foundation('joyride','hide')

    didTransition: ->
      previousTransition = this.get('previousTransition')
      $(".import-icon").addClass("active")
      if previousTransition
        this.set('previousTransition', null)
        previousTransition.retry()
      @_super()

      @viewQueryDemoStuff()

      @controller.set("model.activePage.grid", true)
      Ember.run.later(=>
        try
          $(document).foundation()
        Ember.run.later(->
          $(".grayed-out-form").parent().css("margin-top","-6px")
          $(".grayed-out-form").parent().css("margin-bottom","6px")
        , 500)
      , 1000)

LabCompass.ViewAndQueryResultsRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    model = @storage.createModel "projectGrid"
    unless Ember.isEmpty(params.queryParams.query)
      model.set("query", params.queryParams.query)
    model

  afterModel: (model, transition) ->
    projectID = transition.params.project.projectID
    model.projectID = projectID
    if model.get("query") != null
      model.loadQueryResults(@storage)
      model.set("activePage.query", true)
      model.set("activePage.grid", false)
    else
      @transitionTo("view-and-query.query")

  queryResultsDemoStuff: ->
    dwnldDataBtn = $("#downloadDataButton")
    if dwnldDataBtn.length > 0
      @controller.handleDemoProgress()
    else
      window.setTimeout(=>
        @queryResultsDemoStuff()
      , 100)

  actions:
    willTransition: (transition) ->
      @_super()
      try
        $("#queryResultsJoyride").foundation('joyride','hide')
      if @controller.get("isLoaded") == false
        transition.abort()
      $(".import-icon").removeClass("active")
      @controller.handleTransition(transition)


    didTransition: ->
      @_super()
      @controller.set("model.activePage.grid", true)
      Ember.run.next(=>
        $(".import-icon").addClass("active")
        try
          $(document).foundation()
        @queryResultsDemoStuff()
      )

LabCompass.ViewAndQuerySavedQueriesRoute = LabCompass.ProtectedRoute.extend
  model: (params, transition) ->
    projectID = transition.params.project.projectID
    @storage.getSavedQueries(projectID)
    .then (result) ->
      result

  #This had to be put here because there was somthing weird going on where 
  #we could not access the function within the controller
  handleDemoProgress: ->
    Ember.run.next(=>
      myModel = @modelFor('project')
      if myModel.get("isDemo") == true
        if myModel.get("demoProgress.viewDataSortSearch") == true
          if myModel.get("demoProgress.createNewQuery") == false
            $("#newQueryJoyride").foundation('joyride','off')
            $("#newQueryJoyride").foundation('joyride','start')
            $(".joyride-close-tip").remove()
            $(".joyride-next-tip").css("display", "none")
            $("#buildQueryButton").click(=>
              myModel.set("demoProgress.createNewQuery", true)
              @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))  
            )
    )

  positionSavedQueryButtons: ->
    innerCards = $(".inner-card")
    counter = 0
    while counter != innerCards.length
      if $(innerCards[counter]).height() > 111
        difference = ($(innerCards[counter]).height()-111)/2
        difference = difference + 26
        $(innerCards[counter]).find('.primary').css("margin-top", difference + "px")
      else
        $(innerCards[counter]).find('.primary').css("margin-top", "26px")
      counter++

  actions:
    willTransition: ->
      $(window).off('resize', @positionSavedQueryButtons)
      myModel = @modelFor('project')
      $(".import-icon").removeClass("active")
      if myModel.get("isDemo") == true
        $("#newQueryJoyride").foundation('joyride','hide')

    didTransition: ->
      @_super()
      @positionSavedQueryButtons()
      $(window).on('resize', @positionSavedQueryButtons)
      $(".import-icon").addClass("active")
      @handleDemoProgress()

LabCompass.ViewAndQueryQueryRoute = LabCompass.ProtectedRoute.extend

  model: (params, transition) ->
    if Ember.isEmpty(params.queryParams.query)
      @storage.createNewQuery(@modelFor("project"))
    else
      params.queryParams.query

  afterModel: (model) ->
    if model.get("isChanged") and !Ember.isEmpty(model.get("projectID")) and model.get("queryParams.length") > 0
      Ember.run.later(=>
        Ember.run.next(=>
          @storage.validateQueryParams(model.get("projectID"), model)
        )
      , 500)

  setupController: (controller, model) ->
    @storage.projectGetFormsAndQuestions(@modelFor("project").get("id"))
    .then (result) =>
      parentModel = null
      if Ember.isEmpty(model.get("isSaved")) or model.get("isSaved") == true
        parentModel = model.copy()
        controller.set("showPageErrors", false)
        controller.set("hasParamErrors", false)
      else
        parentModel = @storage.createNewQuery(@modelFor("project"))
      controller.set("parentModel", parentModel)
      controller.set("forms", result.forms)
      controller.set("secondaryIds", result.secondaryIds)
      controller.set("hasBlockedForms", result.formBlocked)
      controller.set("hasBlockedPhi", result.phiBlocked)
      controller.set("model", model)


  actions:
    willTransition: (transition) ->
      $(".import-icon").removeClass("active")
      try
        $("#queryBuildingJoyride").foundation('joyride', 'hide')
      @controller.handleTransition(transition)

    didTransition: ->
      @_super()

      Ember.run.next(=>
        $(".import-icon").addClass("active")
        @controller.handleDemoStuff()
      )
      @controller.setup()




