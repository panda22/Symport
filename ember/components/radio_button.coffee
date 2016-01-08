#radio-button
#used in radio-button-group 
#called with view view.RadioButton
#value: specifies the value of this option
#defaultChecked: set to true on ONLY ONE radiobutton to have it start checked
#allowsEmpty: set to true on allow for 'unclicking'. You probobly want this on every option if its on one option
LabCompass.RadioButton = Ember.Component.extend LabCompass.HighlightParentMixin,
    attributeBindings: ["disabled", "type", "name", "checked"],
    classNames: ["ember-radio-button"],

    value: null,
    selectedValue: null,
    isDisabled: false, #(-> @get 'disabled').property 'disabled',
    checked: false,
    defaultChecked: false,
    allowsEmpty: false,


    tagName: "input",
    type: "radio",

    selectedValueChanged: Ember.observer(->
      selectedValue = @get 'selectedValue'
      checked = (!Ember.isEmpty(selectedValue) && @get('value') == selectedValue )
      #if(checked && @get "checked")
      #  @set "checked", false
      #else
      @set 'checked', checked
    , 'selectedValue')

    checkedChanged: Ember.observer(->
      @_updateElementValue()
    , 'checked')

    init: ->
      @_super()
      @selectedValueChanged()
      @on('click', this, this._change)
      if(@get "defaultChecked")
        @set "checked", true

    _change: ->
      if @get "allowsEmpty"
        @set 'checked', @$().prop('checked') && (!@get("checked") || !@get("allowsEmpty"))
      else
        @set 'checked', @$().prop('checked')
      Ember.run.once(@, @._updateElementValue)

    _updateElementValue: ->
      if @get('checked')
        @set 'selectedValue', @get('value')
      else if @get('value') == @get('selectedValue')
        @set 'selectedValue', null


