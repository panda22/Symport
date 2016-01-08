#Textfield for modal dialouge. Must use this to assign 'enter' action to textfield in modals
#Takes focus on display
#highlightParentDepth: if specified, highlights parent at specified depth

LabCompass.ActionContextTextField = Ember.TextField.extend LabCompass.HighlightParentMixin, LabCompass.SelectTextOnFocusMixin,
  attributeBindings: ["actionContext"]
  takeFocus: false

  becomeFocused: (->
    if @takeFocus
      @$().focus()
      $(document).on 'opened', '[data-reveal]', =>
        @$().focus()
  ).on('didInsertElement')

  releaseHandler: (->
    $(document).off 'opened', '[data-reveal]'
  ).on("willDestroyElement")

  insertNewline: (event) ->
    @sendAction "action", @get 'actionContext'

    if !@get 'bubbles'
      event.stopPropagation()
