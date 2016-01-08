LabCompass.TeamLevelPermissions = LD.Model.extend
  addTeamMember: LD.attr "boolean"
  removeTeamMember: LD.attr "boolean"
  editTeamMember: LD.attr "boolean"
  viewTeamMember: LD.attr "boolean"

  disableAddTeamMember: Ember.computed.not("addTeamMember")
