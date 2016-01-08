LabCompass.EnhancedOptionView = Ember.SelectOption.extend

  attributeBindings: ["disabled"]

  init: ->
    @_super()
    @disabledPathDidChange()

  disabledPathDidChange: ( ->
    disabledPath = @get "parentView.optionDisabledPath"

    return unless disabledPath

    Ember.defineProperty @, "disabled", (->
      @get disabledPath
    ).property disabledPath

  ).observes "parentView.optionDisabledPath"


LabCompass.EnhancedSelect = Ember.Select.extend LabCompass.HighlightParentMixin,

  optionView: LabCompass.EnhancedOptionView