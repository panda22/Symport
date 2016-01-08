LabCompass.WithFormStructure = Ember.Mixin.create
  needs: 'form'
  formStructure: Ember.computed.alias('controllers.form.model')

