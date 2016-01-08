#radio-button
#used in radio-button-group 
#called with view view.RadioButton
#value: specifies the value of this option
#defaultChecked: set to true on ONLY ONE radiobutton to have it start checked
#allowsEmpty: set to true on allow for 'unclicking'. You probobly want this on every option if its on one option
LabCompass.RadioButtonOtherOption = Ember.Component.extend
    attributeBindings: ["disabled", "type", "name", "value", "checked"],
    classNames: ["ember-radio-button"],

    value: null,
    selectedValue: null,
    isDisabled: false, #(-> @get 'disabled').property 'disabled',
    checked: false,
    defaultChecked: false,
    allowsEmpty: false,
    qBuilderPreview: false


    tagName: "input",
    type: "radio",

    selectedValueChanged: Ember.observer(->
      selectedValue = @get 'selectedValue'
      checked = (!Ember.isEmpty(selectedValue) && @get('value') == (selectedValue || "").split("\u200a")[0] )
      if checked
        Ember.run.next =>
          unless Ember.isEmpty @$()
            @$().parent().parent().children()[2].value = selectedValue.split("\u200a")[1] || ""
            $(@$().parent().parent().children()[2]).removeClass("not-selected")
      else
        Ember.run.next =>
          unless Ember.isEmpty @$()
            $(@$().parent().parent().children()[2]).addClass("not-selected")
      @set 'checked', checked
    , 'selectedValue')

    checkedChanged: Ember.observer(->
      @_updateElementValue()
    , 'checked')

    didInsertElement: ->
      isPreview = @_parentView._parentView.get("controller.qBuilderPreview")
      tabindex = if isPreview then "-1" else "0"
      @$().attr("tabindex", tabindex)

    init: ->
      @_super()
      @selectedValueChanged()
      @on('click', this, this._change)
      if(@get "defaultChecked")
        @set "checked", true
      Ember.run.next =>
        unless Ember.isEmpty @$()
          text_field = @$().parent().parent().children()[2]
          if !Ember.isEmpty text_field
            $(text_field).change =>
              Ember.run.once(@, @._updateElementValue)
            $(text_field).click =>
              if !$(@$())[0].checked
                $(@$())[0].checked = true
                @_change()


    _change: ->
      if @get "allowsEmpty"
        @set 'checked', @$().prop('checked') && (!@get("checked") || !@get("allowsEmpty"))
      else
        @set 'checked', @$().prop('checked')
      Ember.run.once(@, @._updateElementValue)

    _updateElementValue: ->
      if @get('checked')
        text = @$().parent().parent().children()[2].value
        if !Ember.isEmpty(text)
          @set 'selectedValue', (@get('value')  + "\u200a" + text )
        else
          @set 'selectedValue', @get('value') 
      else if @get('value') == (@get('selectedValue') || "").split("\u200a")[0]
        @set 'selectedValue', null



