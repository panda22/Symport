#checkboxes-field
#selectedValues: the answer string from FormAnswer.answer. should be different selected options seperated by '\u200c'
#options: the question config from FormAnswer.question.confic.selections
#disabled: allows to be modified
LabCompass.CheckboxesFieldComponent = Ember.Component.extend
  
  disabled: false
  options: []

  #\u200C is a non-printable character
  option: Ember.Checkbox.extend
    checkedObserver: (->
      selectedValues = (@get('selectedValues') || "").split "\u200C"
      value = @get('value')
      if @get 'checked'
        selectedValues.addObject value
      else
        selectedValues.removeObject value
      valuesList = selectedValues.filter (opt) ->
        opt.length > 0
      .join "\u200C"
      @set 'selectedValues', valuesList
    ).observes "checked"

    init: ->
      @_super(arguments...)
      selectedValues = @get('selectedValues') or ""
      value = @get 'value'
      checked = selectedValues.split("\u200C").contains value
      @set "checked", checked
