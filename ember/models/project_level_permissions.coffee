LabCompass.ProjectLevelPermissions = LD.Model.extend
  editSettings: LD.attr "boolean"
  createForms: LD.attr "boolean"
  deleteProject: LD.attr "boolean"

  renameSubjectIDs: LD.attr "boolean"

  disableCreateForms: Ember.computed.not("createForms")
  disableEditSettings: Ember.computed.not("editSettings")
