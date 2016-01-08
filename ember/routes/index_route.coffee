LabCompass.IndexRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo "projects.index"

  actions:
    error: (error, transition, originRoute) ->
      # called when the transition is aborted
