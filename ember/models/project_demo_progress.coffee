LabCompass.ProjectDemoProgress = LD.Model.extend
  id: null
  demoFormId: LD.attr "uuid"
  demoQuestionId: LD.attr "uuid"

  #initial onboarding
  projectIndexGlobal: LD.attr "boolean", default: false
  projectIndexDemoProject: LD.attr "boolean", default: false
  formEnterEdit: LD.attr "boolean", default: false
  enterEditSubjectId: LD.attr "boolean", default: false
  enterEditResponse: LD.attr "boolean", default: false
  enterEditSave: LD.attr "boolean", default: false
  dataTabEmphasis: LD.attr "boolean", default: false
  viewDataSortSearch: LD.attr "boolean", default: false
  
  createNewQuery: LD.attr "boolean", default: false
  buildQueryInfo: LD.attr "boolean", default: false
  buildQueryParams: LD.attr "boolean", default: false
  queryResultsDownload: LD.attr "boolean", default: false
  queryResultsBreadcrumbs: LD.attr "boolean", default: false
  #-------------------  

  #additional onboarding
  formGlobal: LD.attr "boolean", default: false

  teamButton: LD.attr "boolean", default: false
  addNewTeamMember: LD.attr "boolean", default: false
  addTeamMemberPersonalDetails: LD.attr "boolean", default: false
  addTeamMemberProjectPermissions: LD.attr "boolean", default: false
  addTeamMemberFormPermissions: LD.attr "boolean", default: false

  importButton: LD.attr "boolean", default: false
  importOverlays: LD.attr "boolean", default: false
  importCsvText: LD.attr "boolean", default: false

  buildFormButton: LD.attr "boolean", default: false
  formBuilderInfo: LD.attr "boolean", default: false
  buildFormAddQuestion: LD.attr "boolean", default: false
  questionBuilderPrompt: LD.attr "boolean", default: false
  questionBuilderVariable: LD.attr "boolean", default: false
  questionBuilderIdentifying: LD.attr "boolean", default: false

  onboardingCompleted: LD.attr "boolean", default: false
  #-------------------

  projectIndexProgress: (->
    if @get("projectIndexGlobal") == true
      if @get("projectIndexDemoProject") == true
        return true
    return false
  ).property "projectIndexGlobal", "projectIndexDemoProject"

  enterEditProgress: (->
    if @get("enterEditSubjectId") == true
      if @get("enterEditResponse") == true
        if @get("enterEditSave") == true
          return true
    return false
  ).property "enterEditSubjectId", "enterEditResponse", "enterEditSave"

  viewDataProgress: (->
    if @get("dataTabEmphasis") == true
      if @get("viewDataSortSearch") == true
        return true
    return false
  ).property "dataTabEmphasis", "viewDataSortSearch"

  queryBuilderProgress: (->
    if @get("buildQueryInfo") == true
      if @get("buildQueryParams") == true
        return true
    return false
  ).property "buildQueryInfo", "buildQueryParams"

  initialOnboarding: (->
    if @get("projectIndexProgress") == true
      if @get("formEnterEdit") == true
        if @get("enterEditProgress") == true
          if @get("viewDataProgress") == true
            if @get("queryBuilderProgress") == true
              if @get("createNewQuery") == true
                if @get("queryResultsDownload") == true
                  if @get("queryResultsBreadcrumbs") == true
                    return true
    return false
  ).property "projectIndexProgress", "formEnterEdit", "enterEditProgress", "viewDataProgress", "queryBuilderProgress", "queryResultsDownload", "queryResultsBreadcrumbs"

  addTeamMemberProgress: (->
    if @get("teamButton") == true
      if @get("addNewTeamMember") == true
        if @get("addTeamMemberPersonalDetails") == true
          if @get("addTeamMemberProjectPermissions") == true
            if @get("addTeamMemberFormPermissions") == true
              return true
    return false
  ).property "teamButton", "addNewTeamMember", "addTeamMemberPersonalDetails", "addTeamMemberProjectPermissions", "addTeamMemberFormPermissions"

  importProgress: (->
    if @get("importButton") == true
      if @get("importOverlays") == true
        if @get("importCsvText") == true
          return true
    return false
  ).property "importButton", "importOverlays", "importCsvText"

  buildFormProgress: (->
    if @get("buildFormButton") == true
      if @get("formBuilderInfo") == true
        if @get("buildFormAddQuestion") == true
          if @get("questionBuilderPrompt") == true
            if @get("questionBuilderVariable") == true
              if @get("questionBuilderIdentifying") == true
                return true
    return false
  ).property "buildFormButton", "formBuilderInfo", "buildFormAddQuestion", "questionBuilderPrompt", "questionBuilderVariable", "questionBuilderIdentifying"

  additionalOnboarding: (->
    if @get("initialOnboarding") == true
      if @get("formGlobal") == true
        if @get("addTeamMemberProgress") == true
          if @get("importProgress") == true
            if @get("buildFormProgress") == true
              return true
    return false
  ).property "initialOnboarding", "formGlobal", "addTeamMemberProgress", "importProgress", "buildFormProgress"

  displayHelpTooltip: (->
    initialDone = @get "initialOnboarding"
    additionalDone = @get "additionalOnboarding"
    if initialDone && additionalDone
      return true
    return false
  ).property "initialOnboarding", "additionalOnboarding"