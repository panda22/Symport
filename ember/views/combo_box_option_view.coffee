LabCompass.ComboBoxOptionView = Ember.View.extend

  template: Ember.Handlebars.compile "{{option.displayValue}}"
  classNames: ["item", "clickable-div"]
  classNameBindings: ["current"]
  current: Ember.computed.alias "option.selected"

  option: null

  mouseDown: ->
    @get("parentView").send "clickOption", @get "option"

  mouseEnter: ->
    @get("parentView").send "selectOption", @get "option"
