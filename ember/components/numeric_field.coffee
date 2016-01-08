#numeric field with highlight and focus mixins
#allowsDecimal: set to false to dissalow decimal keypress
#allowsSigns: set to true to allow '+/-' characters 
#highlightParentDepth: if specified, highlights parent at specified depth on focus
#takeFocus: if true, elemnt will take focus on didInsert
LabCompass.NumericField = Ember.TextField.extend LabCompass.HighlightParentMixin, LabCompass.TakeFocusMixin,

  allowsDecimal: true
  allowsSigns: false


  classNames: ["number-entry"]

  keyDown: (event) ->
   # Allow: backspace, delete, tab, escape, and enter
   # Allow: Ctrl+A
   # Allow: home, end, left, right
   if (event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || (event.keyCode == 65 && (event.ctrlKey || event.metaKey)) || (event.keyCode >= 35 && event.keyCode <= 39))
     # let it happen, don't do anything
     return
   else
     # Ensure that it is a number and stop the keypress
     if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105) && (event.keyCode != 190 && event.keyCode != 110 && event.keyCode != 189) ) 
       event.preventDefault()
     else
      allowsDecimal = @get "allowsDecimal"
      allowsSigns = @get 'allowsSigns'
      entered_number = @get("value")
      if ((event.keyCode == 190 || event.keyCode == 110) && (!allowsDecimal || entered_number.indexOf(".") >= 0))
        event.preventDefault()
        return
      if (event.keyCode == 189) && (!allowsSigns || entered_number.indexOf("-") >= 0)
        event.preventDefault()
        return