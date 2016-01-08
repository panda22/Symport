LabCompass.ServerInterface = Ember.Object.extend

  authorize: (email, password) ->
    @request
      url: "/session/create"
      type: "POST"
      data:
        user:
          email: email
          password: password

  deauthorize: ->
    @request
      url: "/session"
      type: "DELETE"

  checkSession: ->
    @request
      url: "/session/valid"
      data:
        validate: false

  makeSessionValid: ->
    @request
      url: "/session/valid"
      data:
        validate: true

  createUser: (userInfo, captcha_response) ->
    @request
      url: "/user"
      type: "POST"
      data:
        user: userInfo
        captcha_response: captcha_response

  loadUser: ->
    @request
      url: "/user"
      responseRoot: "user"

  saveUser: (user) ->
    @request
      url: "/user"
      type: "PUT"
      data:
        user: user
      responseRoot: "user"

  saveUserLastVisited: (user) ->
    @request
      url: "/user"
      type: "PUT"
      data:
        user: user
        only_for_last_visited: true
      responseRoot: "user"

  forgotPassword: (email) ->
    @request
      url: "/password_resets"
      type: "POST"
      data:
        user_email: email

  verifyPasswordReset: (updateInfo) ->
    @request
      url: "/password_resets"
      type: "GET"
      data:
        rid: updateInfo.rid
        uid: updateInfo.uid

  updatePassword: (user, rid, uid) ->
    @request
      url: "password_resets"
      type: "PUT"
      data:
        user: user
        rid: rid
        uid: uid

  userInviteSignIn: (uid, iid) ->
    @request
      url: "/pending_user/sign_in/#{uid}/#{iid}"

  userInviteValidate: (uid, iid, user) ->
    @request
      url: "/pending_user/validate"
      type: "POST"
      data:
        id: iid
        user_id: uid
        user_info: user

  getPendingUserFromTeamMember: (userEmail, teamMemberID) ->
    @request
      url: "pending_user/get_from_team_member"
      type: "POST"
      data:
        email: userEmail
        team_member_id: teamMemberID



  loadFormResponse: (formStructureID, subjectID, instanceNumber) ->
    @request
      url: "/form_structures/#{formStructureID}/form_responses/get_by_subject_and_instance"
      type: "POST"
      data:
        subject_id: subjectID
        instance_number: instanceNumber
      responseRoot: "formResponse"

  loadFormResponses: (formStructureID) ->
    @request
      url: "/form_structures/#{formStructureID}/response_query"

  getExistingSubjects: (formStructureID) ->
    @request
      url: "/form_structures/#{formStructureID}/existing_subjects"

  loadFormStructure: (formStructureID) ->
    @request
      url: "/form_structures/#{formStructureID}"
      responseRoot: "formStructure"

  loadProject: (projectID) ->
    @request
      url: "/projects/#{projectID}"
      responseRoot: "project"

  loadProjectTeamMembers: (projectID) ->
    @request
      url: "/projects/#{projectID}/team_members"
      responseRoot: "project"

  canViewProjectPhi: (projectID) ->
    @request
      url: "/projects/can_view_phi/#{projectID}"

  createNewTeamMember: (projectID, teamMemberData) ->
    @request
      type: "POST"
      url: "/projects/#{projectID}/team_members"
      data:
        team_member: teamMemberData
      responseRoot: "teamMember"

  updateDemoProgress: (projectID, demoProgress) ->
    @request
      url: "/projects/#{projectID}/update_demo_progress"
      type: "PUT"
      data:
        demoProgress: demoProgress

  inviteNewUser: (projectID, teamMemberData, firstName, lastName, message) ->
    @request
      type: "POST"
      url: "/pending_user/create_as_team_member/#{projectID}"
      data:
        team_member: teamMemberData
        first_name: firstName
        last_name: lastName
        message: message

  reInviteUser: (pendingUser) ->
    @request
      url: "pending_user/resend"
      type: "POST"
      data: pendingUser

  updateTeamMember: (projectID, teamMemberData) ->
    @request
      type: "PUT"
      url: "/projects/#{projectID}/team_members/#{teamMemberData.id}"
      data:
        team_member: teamMemberData
      responseRoot: "teamMember"

  deleteTeamMember: (projectID, teamMemberID) ->
    @request
      type: "DELETE"
      url: "/projects/#{projectID}/team_members/#{teamMemberID}"
      responseRoot: "project"

  saveImportProgress: (projectID, importData) ->
    console.error "we're gonna do it"

  deleteQuestion: (formStructureID, questionID) ->
    @request
      type: "DELETE"
      url: "/form_structures/#{formStructureID}/form_questions/#{questionID}"
      responseRoot: "formStructure"

  deleteFormStructure: (formStructureID) ->
    @request
      type: "DELETE"
      url: "/form_structures/#{formStructureID}"
      responseRoot: "project"

  deleteFormResponse: (formStructureID, formResponseID) ->
    @request
      type: "DELETE"
      url: "/form_structures/#{formStructureID}/form_responses/#{formResponseID}"
      responseRoot: "formResponse"

  deleteProject: (projectID) ->
    @request
      type: "DELETE"
      url: "/projects/#{projectID}"

  saveFormResponse: (formResponse) ->
    @request
      type: "PUT"
      url: "/form_structures/#{formResponse.formStructureID}/form_responses"
      data:
        id: formResponse.subjectID
        form_response: formResponse
        onlyCheckErrors: false
      responseRoot: "formResponse"

  # NOTE: should this be on LabCompass.Storage?
  saveFormStructure: (projectID, formStructure) ->
    if formStructure.id
      @updateFormStructure formStructure
    else
      @createNewFormStructure projectID, formStructure

  updateFormStructure: (formStructure) ->
    @request
      type: "PUT"
      url: "/form_structures/#{formStructure.id}"
      data:
        form_structure: formStructure
      responseRoot: "formStructure"

  createNewFormStructure: (projectID, formStructure) ->
    @request
      type: "POST"
      url: "/projects/#{projectID}/create_structure"
      data:
        form_structure: formStructure
      responseRoot: "formStructure"

  setResponseSecondaryIds: (formId, secondaryId) ->
    @request
      type: "POST"
      url: "/form_structures/set_response_secondary_ids/#{formId}"
      data:
        secondary_id: secondaryId

  getMaxInstancesInFormStructure: (formID) ->
    @request
      url: "/form_structures/get_max_instances/#{formID}"

  saveProject: (project) ->
    (if project.id then @updateProject else @createNewProject).call(this, project)

  updateProject: (project) ->
    @request
      type: "PUT"
      url: "/projects/#{project.id}"
      data:
        project: project
      responseRoot: "project"

  createNewProject: (project) ->
    @request
      type: "POST"
      url: "/projects"
      data:
        project: project
      responseRoot: "project"

  findKnownSubjects: (projectID) ->
    @request
      url: "/projects/#{projectID}/known_subjects"
      responseRoot: "subjects"

  findSubjectsByForm: (form_id) ->
    @request
      url: "/form_responses/known_subjects_by_form/#{form_id}"

  createResponse: (formID, subjectID, secondaryID) ->
    @request
      type: "POST"
      url: "/form_responses/create_new"
      data:
        form_id: formID
        subject_id: subjectID
        secondary_id: secondaryID

  loadResponse: (responseID) ->
    @request
      url: "/form_responses/find_by_id/#{responseID}"

  renameSubjectID: (projectID, oldSubjectID, newSubjectID) ->
    @request
      type: "PUT"
      url: "/projects/#{projectID}/rename_subject_id"
      data:
        oldSubjectID: oldSubjectID
        newSubjectID: newSubjectID

  renameInstance: (id, secondaryId) ->
    @request
      type: "POST"
      url: "/form_responses/#{id}/rename_instance"
      data:
        secondary_id: secondaryId

  destroyInstancesForSubject: (formID, subjectID) ->
    @request
      type: "POST"
      url: "/form_responses/destroy_instances_for_subject"
      data:
        form_id: formID
        subject_id: subjectID

  getErrorsForFormResponse: (formResponse) ->
    @request
      type: "PUT"
      url: "/form_structures/#{formResponse.formStructureID}/form_responses/#{formResponse.subjectID}"
      data:
        form_response: formResponse
        onlyCheckErrors: true
      responseRoot: "formResponse"

  getErrorsForQuestion: (projectID, questionID, answers) ->
    @request
      type: "PUT"
      url: "/projects/#{projectID}/errors_for_question"
      data:
        question_id: questionID
        answers: answers

  importSampleData1: (projectID, import_struct) ->
    @request
      type: "PUT"
      url: "/projects/#{projectID}/import_sample_data_1"
      data: 
        import_struct: import_struct
      responseRoot: "success"

  importSampleData2: (projectID, import_struct) ->
    @request
      type: "PUT"
      url: "/projects/#{projectID}/import_sample_data_2"
      data: 
        import_struct: import_struct
      responseRoot: "success"

  importFormDataByQuestions: (projectID, import_struct) ->
    @request
      type: "PUT"
      url: "/projects/#{projectID}/import_responses"
      data: 
        import_struct: import_struct
      responseRoot: "success"

  # NOTE: should this be on LabCompass.Storage?
  saveQuestion: (formStructureID, question, prevQuestionID) ->
    if question.id 
      @updateQuestion(formStructureID, question, prevQuestionID)
    else 
      @createNewQuestion(formStructureID, question, prevQuestionID)

  createNewQuestion: (formStructureID, question, prevQuestionID) ->
    @request
      type: "POST"
      url: "/form_structures/#{formStructureID}/form_questions"
      data:
        form_question: question
        prev_id: prevQuestionID
      responseRoot: "formStructure"

  updateQuestion: (formStructureID, question, prevQuestionID) ->
    @request
      type: "PUT"
      url: "/form_structures/#{formStructureID}/form_questions/#{question.id}"
      data:
        form_question: question
        prev_id: prevQuestionID
      responseRoot: "formStructure"

  getQuestion: (formStructureID, questionID) ->
    @request
      type: "GET"
      url: "/form_structures/#{formStructureID}/form_questions/#{questionID}"
      #data:
      #  form_question: question
      #responseRoot: "formStructure"

  loadAllProjects: ->
    @request
      url: "/projects"

  projectViewData: (proj_id) ->
    @request
      url: "/project_view_data/#{proj_id}"

  projectQueryData: (query) ->
    @request
      type: "POST"
      url: "/project_view_data/query"
      data:
        query: query

  projectGetFormsAndQuestions: (proj_id) ->
    @request
      url: "/project_view_data/query/#{proj_id}"

  validateQueryParams: (projectID, query) ->
    @request
      type: "POST"
      url: "/queries/validate"
      data:
        query: query
        project_id: projectID

  getSavedQueries: (projectID, sortType) ->
    @request
      url: "/queries/get_all_queries/#{projectID}/#{sortType}"

  saveQuery: (query) ->
    #goes to create route if new or edit if existing
    hasID = query.id != null
    type = "POST"
    urlPostFix = ""
    if hasID
      type = "PUT"
      urlPostFix = "/#{query.id}"
    @request
      type: type
      url: "/queries#{urlPostFix}"
      data:
        query: query

  saveQueryPermissions: (query) ->
    @request
      type: "POST"
      url: "/queries/edit_permissions"
      data:
        query: query

  deleteQuery: (queryID) ->
    @request
      type: "DELETE"
      url: "/queries/#{queryID}"

  getInitialFormData: (formID) ->
    @request
      url: "/form_data/get_initial_form_data/#{formID}"

  getRemainingFormData: (formID) ->
    @request
      url: "/form_data/get_remaining_form_data/#{formID}"

  updateQuestionFromGrid: (serializedQuestion) ->
    @request
      type: "POST"
      url: "form_data_event/update_question"
      data:
        question: serializedQuestion

  validateQuestionFromGrid: (questionID) ->
    @request
      url: "/form_data_event/get_question_errors/#{questionID}"


  saveAnswersFromGrid: (answerObjects, questionID) ->
    @request
      type: "POST"
      url: "form_data_event/save_answers_for_question"
      data:
        answers: answerObjects
        question_id: questionID

  request: (opts = {}) ->
    ajaxOpts =
      type: opts.type || "GET"
      url: opts.url
      contentType: opts.contentType || "application/json"
      dataType: opts.dataType || "json"
      headers:
       "X-LabCompass-Auth": @session.get("sessionToken")
    if opts.data
      if (opts.type == "POST" || opts.type == "PUT")
        if Em.typeOf(opts.data.asObject) == "function"
          ajaxOpts.data = JSON.stringify opts.data.asObject()
        else
          ajaxOpts.data = JSON.stringify opts.data
      else
        ajaxOpts.data = opts.data
    promise = null
    backToIndexOnError = (xhr, textStatus, errorThrown) =>
      route = @container.lookup("route:application")
      if route
        Ember.run.later =>
          msg = "Something went wrong."
          if xhr.responseJSON && xhr.responseJSON.message
              msg = xhr.responseJSON.message
          route.backToIndexOnError(msg)
    doRequest = =>
      $.ajax(ajaxOpts).statusCode
        401: (xhr, textStatus, errorThrown) =>
          Ember.run.later =>
           @session.expireIfNecessary()
        403: backToIndexOnError
        404: backToIndexOnError
        500: backToIndexOnError

    if LabCompass.testing
      promise = new Ember.RSVP.Promise (resolve, reject) ->
        Ember.run =>
          doRequest().then (stuff) =>
            resolve stuff
          , (stuff) ->
            reject stuff
    else
      promise = doRequest()
    if opts.responseRoot
      promise.then (JSONResponse) -> JSONResponse[opts.responseRoot]
    else
      promise

$.ajaxSetup cache: false
LabCompass.register "storage-interface:server", LabCompass.ServerInterface
LabCompass.inject "storage-interface:server", "session", "session:main"
