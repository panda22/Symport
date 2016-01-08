LabCompass.ResponseLogicMixin = Ember.Mixin.create

  formResponse: Ember.computed.alias("model")
  logicCoordinator: null
  setupLogicCoordinator: (->
    coordinator = @container.lookup "logic:response"
    coordinator.set "formResponse", @get "formResponse"
    @set "logicCoordinator", coordinator
  ).observes("formResponse").on "init"

