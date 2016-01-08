LabCompass.Project = LD.Model.extend
  id: null
  name: LD.attr "string"
  attribution: LD.attr "string"
  isDemo: LD.attr "boolean"
  
  shortName: (->
    str = @get("name")
    length = str.length
    if length > 27
       str = str.substring(0, 27) + "..."
    else
      return str
  ).property("name")

  projectShortName: (->
    str = @get("name")
    length = str.length
    if length > 42
      str = str.substring(0,42) + "..."
    else
      return str
  ).property("name")

  formShortName: (->
    str = @get("name")
    length = str.length
    if length > 39
      str = str.substring(0,39) + "..."
    else
      return str
  ).property("name")

  hoverId: Ember.computed(->
    projectId = @get("id")
    hoverName = "hover" + projectId
    return hoverName
  )

  structures: LD.hasMany "formStructure"
  teamMembers: LD.hasMany "teamMember"
  lastEdited: LD.attr "string"
  formsCount: LD.attr "number"
  subjectsCount: LD.attr "number"
  administratorNames: LD.attr "string"

  demoProgress: LD.hasOne "projectDemoProgress"
  userPermissions: LD.hasOne "projectLevelPermissions"
  userTeamPermissions: LD.hasOne "teamLevelPermissions"

  structureSorting: ["lastEdited:desc"]
  sortedStructures: Ember.computed.sort "structures", 'structureSorting'