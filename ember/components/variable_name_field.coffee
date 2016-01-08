#text field used for specifying a variable name. Will dissalow certain chars and turns spaces into underscores
LabCompass.VariableNameField = Ember.TextField.extend LabCompass.HighlightParentMixin,
  keyDown: (event) ->
    #convert space to underscore and reset cursor
    #depends on input field having class "question-variable-name"
    if (event.keyCode == 0 || event.keyCode == 32)
      domObj = @$()
      jsDomObj = domObj.get(0)
      start =  jsDomObj.selectionStart
      end = jsDomObj.selectionEnd
      val = domObj.val()
      newVal = [val.slice(0, start), "_", val.slice(end)].join("")
      domObj.val(newVal)
      jsDomObj.setSelectionRange(start + 1, start + 1)
      event.preventDefault()
    # Allow: backspace, delete, tab, escape, and enter
    # Allow: Ctrl+A
    # Allow: home, end, left, right
    # Allow: Underscore, 189 is the - character
    if ((event.keyCode == 189 && event.shiftKey == true) || event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || (event.keyCode == 65 && event.ctrlKey == true) || (event.keyCode >= 35 && event.keyCode <= 39))
      # let it happen, don't do anything
      return
    else
    # Ensure that it is a number/digit/underscore and stop the keypress
      if (event.shiftKey && ((event.keyCode >= 65 && event.keyCode <= 90)))
      else if (event.shiftKey)
        event.preventDefault()
      if (event.keyCode < 48 || event.keyCode > 90)
        event.preventDefault()

  didInsertElement: ->
    @$().bind("paste", (e) ->
      domObj = $(this)
      jsDomObj = domObj.get(0)
      start =  jsDomObj.selectionStart
      end = jsDomObj.selectionEnd
      val = domObj.val()
      insertedVal = e.originalEvent
        .clipboardData
        .getData('text/plain')
        .replace(/\s/g, "_")
      newVal = [val.slice(0, start), insertedVal, val.slice(end)].join("")
      domObj.val(newVal)
      jsDomObj.setSelectionRange(start + insertedVal.length, start + insertedVal.length)
      e.preventDefault()
    )