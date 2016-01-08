LabCompass.ErrorController = Ember.ObjectController.extend
  actions:
    ok: ->
      @send "closeDialog"
      @transitionToRoute "projects.index"
