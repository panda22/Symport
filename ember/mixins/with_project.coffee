LabCompass.WithProject = Ember.Mixin.create
  needs: ['project']
  project: Ember.computed.alias('controllers.project.model')

