#checkboxes-field
#selectedValues: the answer string from FormAnswer.answer. should be different selected options seperated by '\u200c'
#options: the question config from FormAnswer.question.confic.selections
#disabled: allows to be modified
LabCompass.CheckboxesFieldOtherOptionComponent = Ember.Component.extend
  
  disabled: false
  options: []
  qBuilderPreview: false

  #\u200C is a non-printable character
  option: Ember.Checkbox.extend
    attributeBindings: ["option_value"]
    checkedObserver: (->
      selectedValues = (@get('selectedValues') || "").split("\u200C")
      value = @get('value')
      
      for checkbox_option in $(@$()).parent().parent().parent().find(".checkbox-option")
        box = $(checkbox_option).children()[0].children[0]
        option_value = box.getAttribute("option_value")
        if option_value == value
          text_field = $(checkbox_option).children()[2]
          text = text_field.value
          if text != undefined
            if @get 'checked'
              selectedValues.addObject (value + "\u200a" + text) #selectedValues.addObject value
              $(text_field).removeClass("not-selected") 
            else
              selectedValues = selectedValues.filter (opt) ->
                opt.split("\u200a")[0] != value  
              $(text_field).addClass("not-selected")          
          else
            if @get 'checked'
              selectedValues.addObject value #selectedValues.addObject value
            else
              selectedValues.removeObject value            

      valuesList = selectedValues.filter (opt) ->
        opt.length > 0 && opt != "\u200d"
      .join "\u200C"

      @set 'selectedValues', valuesList
    ).observes "checked"

    didInsertElement: ->
      isPreview = @_parentView._parentView.get("controller.qBuilderPreview")
      tabindex = if isPreview then "-1" else "0"
      @$().attr("tabindex", tabindex)

    init: ->
      @_super(arguments...)
      selectedValues = (@get('selectedValues') || "")
      value = @get 'value'
      checked = false
      text_field = null
      unless Ember.isEmpty @$()
        text_field = $($(@$()).parent().parent().children()[2])
      for val in selectedValues.split("\u200C")
        if val.split("\u200a")[0] == value
          checked = true
          fill = val.split("\u200a")[1]
          Ember.run.next =>
            unless Ember.isEmpty @$()
              $(@$()).parent().parent().children()[2].value = fill
      
      @set 'checked', checked
      Ember.run.next =>
        unless Ember.isEmpty @$()
          $($(@$()).parent().parent().children()[2]).click =>
            @set 'checked', true
          $($(@$()).parent().parent().children()[2]).change =>
            @set 'checked', false

            Ember.run.next =>
              @set 'checked', true

      if !checked
        Ember.run.next =>
          unless Ember.isEmpty @$()
            $($($(@$()).parent().parent().children()[2])).addClass("not-selected")
      if @get('disabled')
        Ember.run.next =>
          unless Ember.isEmpty @$()
            $(@$()).parent().parent().children()[2].disabled = true