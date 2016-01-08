LabCompass.AutosizeTextArea = Ember.TextArea.extend LabCompass.HighlightParentMixin, LabCompass.TakeFocusMixin, LabCompass.SelectTextOnFocusMixin,
  qBuilderPreview: false
  cantResize: false

  didInsertElement: ->
    autosize(@$())
    isPreview = @_parentView._parentView.get("controller.qBuilderPreview")
    tabindex = if isPreview then "-1" else "0"
    @$().attr("tabindex", tabindex)
    if @cantResize
    	$(".question-prompt").css("resize","vertical")