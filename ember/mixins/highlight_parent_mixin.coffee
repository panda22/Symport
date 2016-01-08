#highlights a parent HTML element on focus 
#adds background color on focusOut
#takes away the background on focusOut

LabCompass.HighlightParentMixin = Ember.Mixin.create

  highlightParentDepth: -1
  #specifies depth of parent to highlight
  #leave blank to disable highlighting
  
  setFocusHighlightListener: (->
    @$().on 'focus', =>
      unless (@get "highlightParentDepth") == -1
        @$().parents()[@get "highlightParentDepth"].setAttribute("style", "background: #D4f4E4")
  ).on('didInsertElement')


  focusOut: (event) ->
    unless (@get "highlightParentDepth") == -1
      @$().parents()[@get "highlightParentDepth"].setAttribute("style", "background: none")

  focusout: (event) ->
    unless (@get "highlightParentDepth") == -1
      @$().parents()[@get "highlightParentDepth"].setAttribute("style", "background: none")