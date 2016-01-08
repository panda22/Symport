#radio buttons manager
#call this with 'view view.RadioButton' as children for every option
#has highlight parent mixin
#highlightParentDepth: if specified, highlights parent at specified depth

LabCompass.RadioButtonGroupOtherOption = Ember.Component.extend LabCompass.HighlightParentMixin,

    classNames: ['ember-radio-button-group']
    attributeBindings: ['name:data-name']
    value: false,
 
#  init: ->
#    @_super()
#    if get("disabled")
#      Ember.run.next =>
#        for text in $(@$()).parent().parent().find(".other-text")
#          text.disabled = true

    
    RadioButton: Ember.computed(->
      LabCompass.RadioButtonOtherOption.extend
        group: this,
        selectedValueBinding: 'group.value',
        nameBinding: 'group.name',
        disabledBinding: 'group.disabled'
    )

