LabCompass.EmailField = Ember.TextField.extend

  classNames: ["email"]

  # keyDown: (event) ->
  #  # Allow: backspace, delete, tab, escape, and enter
  #  # Allow: Ctrl+A
  #  # Allow: home, end, left, right
  #  if (event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || (event.keyCode == 65 && event.ctrlKey == true) || (event.keyCode >= 35 && event.keyCode <= 39))
  #    # let it happen, don't do anything
  #    return
  #  else
  #    # Ensure that it is a number and stop the keypress
  #    if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105) || @get("value").length >= 5)
  #      event.preventDefault()
