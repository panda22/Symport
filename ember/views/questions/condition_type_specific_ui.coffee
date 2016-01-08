LabCompass.ConditionTypeSpecificUI = LabCompass.DynamicContentView.extend LabCompass.HighlightParentMixin,
  question: null
  condition: null
  disabled: false

  makeView: (->
    type = @get "question.type"
    conditionView = @container.lookup "questionUI:#{type}.operand"
    unless conditionView
      conditionView = Ember.View.create
        template: Ember.Handlebars.compile "Unsupported question condition UI for type #{type}"
    conditionView.setProperties
      question: @get "question"
      condition: @get "condition"
      disabled: @get "disabled"
    @set "dynamicView", conditionView
  ).observes("question.type", "question").on "init"
