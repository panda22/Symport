
# Storage is the interface used by LabCompass to access persistent storage
# Depending on the underlying storage interface, this could be:
# - memory
# - a backend server via JSON API
#
# This layer should accept, return, or manipulate only LD.Model objects.
#
# The underlying @interface accepts and returns only regular JSON objects.
# This class is responsible for (de)serializing.
#

LabCompass.Storage = LD.Storage.extend

  interfaceName: "server"

  authorize: (email, password) ->
    @get("interface").authorize email, password
    .then (authInfo) =>
      user = @createModel "user", authInfo.user
      @session.beginSession authInfo.sessionToken, user

  deauthorize: ->
    @get("interface").deauthorize()

  checkSession: ->
    @get("interface").checkSession()

  makeSessionValid: ->
    @get("interface").makeSessionValid()

  createUser: (user, captcha_response) ->
    @get("interface").createUser(user.serialize(), captcha_response)
    .then (authInfo) =>
      user = @createModel "user", authInfo.user
      @session.beginSession authInfo.sessionToken, user
    , (errorInfo) ->
      resp = errorInfo.responseJSON
      if typeof resp.validations.password != 'undefined' && resp.validations.password.length > 0
        if resp.validations.password[0] == "can't be blank"
          resp.validations.password[0] = "Please enter a valid password"
      if typeof resp.validations.passwordConfirmation != 'undefined' && resp.validations.passwordConfirmation.length > 0
        if resp.validations.passwordConfirmation[0] == "doesn't match Password"
          resp.validations.passwordConfirmation[0] = "Make sure both passwords match"
      if resp.validations
        user.applyErrors resp.validations
      resp.error

  loadUser: ->
    @get("interface").loadUser()
    .then (userJSON) =>
      @createModel "user", userJSON

  saveUser: (user) ->
    @get("interface").saveUser user.serialize()
    .then (userJSON) =>
      user.setProperties userJSON
      user.setProperties
        currentPassword: null
        password: null
        passwordConfirmation: null
      user
    , (errorInfo) ->
      resp = errorInfo.responseJSON
      if resp.validations
        user.applyErrors resp.validations
      resp.error

  saveUserLastVisited: (user) ->
    @get("interface").saveUserLastVisited user.serialize()

  forgotPassword: (email) ->
    @get("interface").forgotPassword(email)
    .then (result) ->
      result
    , (errorInfo) ->
      errorInfo

  verifyPasswordReset: (uid, rid) ->
    @get("interface").verifyPasswordReset({"uid": uid, "rid":rid})
    .then (result) =>
      if result.result == true
        user = @createModel("user", result.user)
        user.setProperties
          currentPassword: null
          password: null
          passwordConfirmation: null
        return user
      else
        return null
    , (errorInfo) ->
      return null

  updatePassword: (user, rid, uid) ->
    @get("interface").updatePassword(user.serialize(), rid, uid)
    .then (result) =>
      result.result
    , (errorInfo) ->
      if errorInfo.responseJSON and errorInfo.responseJSON.validations
        errorInfo.responseJSON.validations

  userInviteSignIn: (uid, iid) ->
    @get("interface").userInviteSignIn(uid, iid).then (result) =>
      #TODO add error handler
      model
      if result.user == null
        model = @createModel("user")
        model.set("isError", true)
      else
        model = @createModel("user", result.user)
        model.set("inviteID", iid)
        model.set("id", uid)
        model.set("isError", false)
      model
    , (error) =>
      model = @createModel("user")
      model.set("isError", true)
      model

  userInviteValidate: (user) ->
    @get("interface").userInviteValidate(user.get("id"), user.get("inviteID"), user.serialize())
    .then (authInfo) =>
      user = @createModel "user", authInfo.user
      @session.beginSession authInfo.sessionToken, user
    , (errorInfo) ->
      resp = errorInfo.responseJSON
      if resp.validations
        user.applyErrors resp.validations
      resp.error

  getPendingUserFromTeamMember: (userEmail, teamMemberID) ->
    @get("interface").getPendingUserFromTeamMember(userEmail, teamMemberID)
    .then (result) =>
      @createModel "pendingUser", result


  createNewProject: ->
    @createModel "project"

  createNewFormStructure: ->
    @createModel "formStructure"

  createNewQuery: (project=null) ->
    newQuery = @createModel "query"
    if project != null
      newQuery.set("projectID", project.get("id"))
      for form in project.get("structures.content")
        queryFormJSON = {
          formID: form.id,
          included: true,
          formName: form.get("name"),
          displayed: form.get("userPermissions.viewData")
        }
        newQuery.get("queriedForms.content").push(
            @createModel("queryFormStructure", queryFormJSON)
          )
    newQuery



  saveQuestion: (formStructure, question, prevQuestionID) ->
    @get("interface").saveQuestion(formStructure.get('id'), question.serialize(), prevQuestionID)
    .then (newJSON) ->
      formStructure.setProperties newJSON
      formStructure
    , (errorStuff) ->
      question.applyErrors errorStuff.responseJSON.validations


  deleteQuestion: (formStructure, question) ->
    formStructureID = formStructure.get("id")
    questionID = question.get("id")
    @get("interface").deleteQuestion(formStructureID, questionID).then (newJSON) ->
      formStructure.setProperties newJSON
    # to pull out into helper and use:
    # for each question in new structure...
      # get the existing question model out of formStructure
      # update attrs on question model (this will prevent flickering)
      # if not exist in our formStructure, create new question and add it
    # for our questions that were not in formStructureJSON, remove from formStructure

  getQuestion: (formStructureID, questionID, switchAllSelectionsToDropDown=false) ->
    @get("interface").getQuestion(formStructureID, questionID).then (result) =>
      if switchAllSelectionsToDropDown
        switch result.formQuestion.type
          when "checkbox", "radio", "yesno"
            result.formQuestion.type = "dropdown"
      @createModel("formQuestion", result.formQuestion)

  deleteFormStructure: (project, formStructure) ->
    projectID = project.get("id")
    formStructureID = formStructure.get('id')
    @get('interface').deleteFormStructure(formStructureID).then (newJSON) ->
      project.setProperties newJSON

  deleteProject: (project) ->
    projectID = project.get("id")
    @get('interface').deleteProject(projectID)

  deleteFormResponse: (formStructure, formResponse) ->
    @get("interface").deleteFormResponse(formStructure.get("id"), formResponse.get("id"))

  saveFormStructure: (project, formStructure) ->
    formStructureJSON = formStructure.getProperties("id", "name", "isManyToOne", "secondaryId", "isSecondaryIdSorted", "description")
    isNewForm = (formStructureJSON.id == null)
    @get("interface").saveFormStructure(project.get('id'), formStructureJSON)
    .then (savedJson) =>
      projectStructures = project.get "structures"
      formStructure.setProperties savedJson
      if isNewForm
        projectStructures.addObject formStructure
      else
        projectStructures
          .findProperty("id", formStructure.id)
          .setProperties(
            formStructure.getProperties(
              "id",
              "name",
              "isManyToOne",
              "secondaryId",
              "isSecondaryIdSorted"  
            )
          )
      formStructure
    , (errorStuff) =>
      formStructure.applyErrors errorStuff.responseJSON.validations

  updateFormStructure: (project, formStructure) ->
    formStructureJSON = formStructure.getProperties("id", "name", "isManyToOne", "secondaryId", "isSecondaryIdSorted", "description")
    @get("interface").saveFormStructure(project.get('id'), formStructureJSON)
    .then (savedJson) =>
      projectStructures = project.get "structures"
      formStructure.setProperties savedJson
    , (errorStuff) =>
      formStructure.applyErrors errorStuff.responseJSON.validations

  setResponseSecondaryIds: (formStructure, newSecondaryId) ->
    @get("interface").setResponseSecondaryIds(formStructure.id, newSecondaryId)
    .then (result) ->
      result
    , (errorStuff) =>
      formStructure.applyErrors errorStuff.responseJSON.validations

  getMaxInstancesInFormStructure: (formID) ->
    @get("interface").getMaxInstancesInFormStructure(formID)
    .then (result) ->
      result.numInstances



  saveProject: (project) ->
    projectJSON = project.getProperties("id", "name", "attribution")
    @get("interface").saveProject(projectJSON)
    .then (savedJson) =>
      project.setProperties savedJson
    , (errorStuff) =>
      project.applyErrors errorStuff.responseJSON.validations

  #     @createHandler("project"),
  #     @errorHandler(project))

  # createHandler: (klass) ->
  #   (savedJSON) =>
  #     @createModel klass, savedJSON

  # errorHandler: (model) ->
  #   (errorStuff) ->
  #     model.applyErrors errorStuff.responseJSON.validations

  canViewProjectPhi: (projectID) ->
    @get("interface").canViewProjectPhi(projectID).then (result) =>
      return result.view_phi

  saveFormResponse: (formResponse) ->
    answers = formResponse.get('answers')
    answers.forEach (a) -> a.clearAnswerIfDisabled()
    formResponseJSON =
      subjectID: formResponse.get 'subjectID'
      formStructureID: formResponse.get 'formStructure.id'
      instanceNumber: formResponse.get 'instanceNumber'
      secondaryId: formResponse.get 'secondaryId'
      answers: answers.map (answer) ->
        id: answer.get('id')
        answer: answer.get('answer')
        question: answer.get('question.id')


    @get("interface").saveFormResponse(formResponseJSON).then (response) =>
      newResponse = @createModel "formResponse", response
      newResponse.set("isDisplayed", true)
      {response: newResponse, numEntries: response.formStructure.responsesCount}
    , (errorStuff) =>
      if errorStuff.responseJSON == undefined
        formResponse
      else
        formResponse.applyErrors errorStuff.responseJSON.validations

  importSampleData1: (projectID) ->
    file_name = "sample name 1"
    form_struct = 
      id: null
      name: file_name
      isManyToOne: false
      secondaryId: null

    import_struct = 
      file_name: file_name
      struct: form_struct
      subject_ids: []
      question_columns: []

    @get('interface').importSampleData1 projectID, import_struct

  importSampleData2: (projectID) ->
    file_name = "sample name 2"
    form_struct = 
      id: null
      name: file_name
      isManyToOne: true
      secondaryId: 'Visit'

    import_struct = 
      file_name: file_name
      struct: form_struct
      subject_ids: []
      question_columns: []

    @get('interface').importSampleData2 projectID, import_struct

  importFormDataByQuestions: (projectID, form_info, subjects_column, question_columns, file_name, mode) ->
    import_struct =
      file_name: file_name
      struct: form_info
      subject_ids: subjects_column
      question_columns: question_columns
      mode: mode
      
    @get('interface').importFormDataByQuestions projectID, import_struct

  getErrorsForQuestion: (projectID, questionID, answers) ->
    @get("interface").getErrorsForQuestion(projectID, questionID, answers).then (results) ->
      results
  
  updateDemoProgress: (projectID, demoProgress)->
    @get("interface").updateDemoProgress(projectID, demoProgress.serialize())

  getErrorsForFormResponse: (formResponse) ->
    answers = formResponse.get('answers').content
    answers.forEach (a) -> a.clearAnswerIfDisabled()
    formResponseJSON =
      subjectID: formResponse.get('subjectID')
      formStructureID: formResponse.get('formStructure').id
      answers: answers.map (answer) ->
        id: answer.id
        answer: answer.get('answer')
        question: answer.get('question').id
    
    @get("interface").getErrorsForFormResponse(formResponseJSON).then (response) =>
      {response: (@createModel "formResponse", response), numEntries: response.formStructure.responsesCount}
    , (errorStuff) =>
      if errorStuff.responseJSON == undefined
        formResponse
      else
        formResponse.applyErrors errorStuff.responseJSON.validations

  loadFormStructure: (formStructureID) ->
    @get("interface").loadFormStructure(formStructureID).then (v) =>
      @createModel "formStructure", v

  getExistingSubjects: (formStructureID) ->
    @get("interface").getExistingSubjects(formStructureID).then (subjects) =>
      subjects

  loadProject: (projectID) ->
    @get("interface").loadProject(projectID).then (v) =>
      @createModel "project", v      

  # { project: { teamMembers: [] } }
  loadTeamMembersIntoProject: (project) ->
    @get("interface").loadProjectTeamMembers(project.get('id')).then (responseJSON) =>
      project.set("teamMembers", responseJSON.teamMembers)
      project.set("userTeamPermissions", responseJSON.userTeamPermissions)
      project

  createNewTeamMember: (project, teamMember) ->
    @get("interface").createNewTeamMember(project.get('id'), teamMember.serialize()).then (responseJSON) =>
      teamMember = @createModel "teamMember", responseJSON
      project.get('teamMembers').addObject(teamMember)
    , (errorStuff) =>
      validations = errorStuff.responseJSON.validations
      teamMember.applyErrors validations
      if validations.canCreateNewUser
        return validations.canCreateNewUser
      else
        return false

  inviteNewUser: (project, teamMember, firstName, lastName, message) ->
    @get("interface").inviteNewUser(project.get("id"), teamMember.serialize(), firstName, lastName, message)
    .then (result) =>
      if result.success == true
        teamMember = @createModel "teamMember", result.team_member
        project.get('teamMembers').addObject(teamMember)
        return result
    , (errorInfo) =>
      resp = errorInfo.responseJSON
      if resp.validations
        teamMember.applyErrors resp.validations
      resp.error

  reInviteUser: (pendingUser) ->
    params = pendingUser.serialize()
    params["user_email"] = params["email"]
    delete params["email"]
    @get("interface").reInviteUser(params)
    .then (result) ->
      return result





  updateTeamMember: (project, teamMember) ->
    @get("interface").updateTeamMember(project.get('id'), teamMember.serialize()).then (responseJSON) =>
      @createModel "teamMember", responseJSON
    , (errorStuff) =>
      teamMember.applyErrors errorStuff.responseJSON.validations

  deleteTeamMember: (project, teamMember) ->
    @get("interface").deleteTeamMember(project.get('id'), teamMember.get('id')).then (responseJSON) =>
      project.setProperties responseJSON
    , (errorStuff) =>
      teamMember.applyErrors errorStuff.responseJSON.validations

  saveImportProgress:(project, importProgress) ->    
    @get("interface").saveImportProgress(project.get('id'), importProgress.serialize())


  loadFormResponse: (formStructure, subjectID, instanceNumber=0) ->
    @get("interface").loadFormResponse(formStructure.get("id"), subjectID, instanceNumber).then (v) =>
      @createModel "formResponse", v
    , (errorStuff) =>
      errorStuff.responseJSON

  loadFormResponses: (formStructureID) ->
    @get("interface").loadFormResponses(formStructureID).then (responsesInfo) =>
      responsesInfo

  createResponse: (form, subjectID, secondaryID) ->
    @get("interface").createResponse(form.id, subjectID, secondaryID)
    .then (result) =>
      @createModel("formResponse", result)


  loadResponse: (responseID) ->
    @get("interface").loadResponse(responseID)
    .then (result) =>
      @createModel("formResponse", result)


  findKnownSubjects: (project) ->
    @get("interface").findKnownSubjects project.get("id")

  findSubjectsByForm: (formStructure) ->
    @get("interface").findSubjectsByForm(formStructure.id).then (result) ->
      result.form_responses

  renameSubjectID: (project, oldSubjectID, newSubjectID) ->
    @get("interface").renameSubjectID project.get("id"), oldSubjectID, newSubjectID

  renameInstance: (response, secondaryId) ->
    @get("interface").renameInstance(response.get("id"), secondaryId)
    .then (result) =>
      @createModel("formResponse", result.formResponse)
    , (errorStuff) =>
      response.applyErrors(errorStuff.responseJSON.validations)

  destroyInstancesForSubject: (formID, subjectID) ->
    @get("interface").destroyInstancesForSubject(formID, subjectID)


  loadAllProjects: ->
    @get("interface").loadAllProjects().then (resp) =>
      resp.projects.map (s) => 
        @createModel "project", s

  projectViewData: (proj_id) ->
    @get("interface").projectViewData(proj_id).then (result) =>
      if result
        retObj = {}
        retObj.grid = result.grid
        retObj.formIndexes = result.form_indexes
        retObj.header = result.gridHeader
        retObj.subjectDates = result.subjectDates
        retObj.noDataError = result.noDataError
        retObj.canExport = result.canExport
        retObj.formBlocked = result.formBlocked
        retObj.questionToForm = result.questionToForm
        retObj
      else
        null
    , (error) ->
      null

  projectQueryData: (query) ->
    @get("interface").projectQueryData(query.serialize()).then (result) =>
      return result

  projectGetFormsAndQuestions: (proj_id) ->
    @get("interface").projectGetFormsAndQuestions(proj_id).then (result) =>
      if result
        retObj = {}
        retObj.forms = result.forms
        retObj.formBlocked = result.formBlocked
        retObj.secondaryIds = result.secondaryIds
        retObj.phiBlocked = result.phiBlocked
        retObj
      else
        null
    , (error) ->
      console.error(error)
      null

  validateQueryParams: (projectID, query) ->
    @get("interface").validateQueryParams(projectID, query.serialize())
    .then (result) ->
      return result
    , (errorStuff) ->
      for param, i in query.get("queryParams.content")
        param.applyErrors(errorStuff.responseJSON.queries[i])
      query


  getSavedQueries: (projectID, sortType="editedDescending") ->
    @get("interface").getSavedQueries(projectID, sortType)
    .then (result) =>
      queries = []
      for queryInfo, i in result.queries
        query = @createModel("query", queryInfo)
        for param, j in query.get("queryParams.content")
          error = result.paramErrors[i][j]
          if Ember.keys(error).length > 0
            query.set("isChanged", true)
          param.applyErrors(error)
        queries.push(query)
      queries

  saveQuery: (query) ->
    @get("interface").saveQuery(query.serialize())
    .then (result) =>
      query.setProperties
        id: result.id
        isChanged: result.isChanged
        changeMessage: result.changeMessage
        ownerName: result.ownerName
        created: result.created
        editorName: result.editorName
        edited: result.edited
        conjunction: result.conjunction
      result
    , (errorStuff) ->
      query.applyErrors(errorStuff.responseJSON.validations)
      for param, i in query.get("queryParams.content")
        param.applyErrors(errorStuff.responseJSON.queries[i])

  saveQueryPermissions: (query) ->
    @get("interface").saveQueryPermissions(query.serialize())
    .then (result) =>
      @createModel("query", result)
    , (errorStuff) ->
      query.applyErrors(errorStuff.responseJSON.validations)


  deleteQuery: (query) ->
    @get("interface").deleteQuery(query.get("id"))


  getInitialFormData: (formID) ->
    @get("interface").getInitialFormData(formID)

  getRemainingFormData: (formID) ->
    @get("interface").getRemainingFormData(formID)

  updateQuestionFromGrid: (question) ->
    @get("interface").updateQuestionFromGrid(question.serialize())
    .then (result) =>
      result
    , (errorStuff) ->
      question.applyErrors errorStuff.responseJSON.validations

  validateQuestionFromGrid: (questionID) ->
    @get("interface").validateQuestionFromGrid(questionID)

  saveAnswersFromGrid: (answerObjects, questionID) ->
    @get("interface").saveAnswersFromGrid(answerObjects, questionID)

  constructFormDataArray: (project, formID=null) ->
    formDataArr = Ember.A([])
    formArrayCopy =  project.get("structures.content").slice()
    # TODO: add sort as parameter or allow dynamic sorting
    formArrayCopy.sort( (a, b) ->
      if a.get("name") == b.get("name")
        return 0
      else if a.get("name") > b.get("name")
        return 1
      else
        return -1
    )
    for form in formArrayCopy
      props = {
        formID: form.id,
        formName: form.get("name"),
        dataDriver: new LabCompass.GridDataDriver(),
        curSortVariable: "subjectID",
        secondaryId: form.get("secondaryId"),
        answerErrors: @createModel("formDataErrors"),
        isInitActive: (form.id == formID),
        color: form.get("color")
      }
      newFormData = @createModel("formData", props)
      formDataArr.pushObject(newFormData)
    formDataArr

  setFormDataFormStructure: (model) ->
    Ember.run.scheduleOnce("afterRender", =>
      if model.get("canView") == true
        @loadFormStructure(model.get("formID")).then (result) ->
          model.set("formStructure", result)
      else
        model.set("formStructure", null)
    )


LabCompass.register "storage:main", LabCompass.Storage
LabCompass.inject "storage:main", "session", "session:main"
LabCompass.inject "route", "storage", "storage:main"
LabCompass.inject "controller", "storage", "storage:main"
