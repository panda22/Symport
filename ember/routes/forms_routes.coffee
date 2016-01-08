LabCompass.FormRoute = LabCompass.ProtectedRoute.extend
  model: (params) ->
    @storage.loadFormStructure params.formID

  serialize: (model) ->
    formID: model.get('id')

LabCompass.FormPreviewRoute = LabCompass.ProtectedRoute.extend
  actions:
    didTransition: ->
      @_super()
      newFakeAnswers = @controller.getFakeAnswers()
      @controller.set("fakeAnswers", newFakeAnswers)
      @controller.setupDisplayedQuestions()

LabCompass.FormBuildRoute = LabCompass.ProtectedRoute.extend
  actions:
    willTransition: ->
      $("#buildFormJoyride").foundation('joyride', 'hide')
    didTransition: ->
      @send "loadingOff"
      @_super()
      @controller.setupDisplayedQuestions()
      @controller.handleDemoProgress()

LabCompass.FormGridRoute = LabCompass.ProtectedRoute.extend
  # activate: ->
  #   if @get('controller')
  #     @get('controller').loadResponses()

  # setupController: (controller) ->
  #   controller.setup @modelFor "form"
  beforeModel: ->
    @send "loadingOn"

  model: ->
  	@modelFor "form"

  afterModel: (curmodel, transition) ->
  	formID = transition.params.form.formID
  	@storage.loadFormResponses(formID).then (response) ->
      curmodel.set("grid", response.grid)
      curmodel.set("header", response.gridHeader)
      curmodel.set("subjectDates", response.subjectDates)
      Ember.run.next(->
        curmodel.set("allCompleted", true)
      )

  actions:
    willTransition: ->
      @_super()
      @get("controller").resetController()

