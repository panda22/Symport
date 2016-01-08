#radio buttons manager
#call this with 'view view.RadioButton' as children for every option
#has highlight parent mixin
#highlightParentDepth: if specified, highlights parent at specified depth

LabCompass.RadioButtonGroup = Ember.Component.extend

    classNames: ['ember-radio-button-group']
    attributeBindings: ['name:data-name']
    value: false,

    RadioButton: Ember.computed(->
      LabCompass.RadioButton.extend
        group: this,
        selectedValueBinding: 'group.value',
        nameBinding: 'group.name',
        disabledBinding: 'group.disabled'
    )

