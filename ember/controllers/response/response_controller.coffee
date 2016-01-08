LabCompass.ResponseController = Ember.ObjectController.extend LabCompass.WithProject,

  breadCrumb: (->
    "Subject ID - #{@get('model.subjectID')}"
  ).property("model.subjectID")

  breadCrumbPath: false

  otherForms: (->
    @get('project.structures').filter (form) =>
      if form.get('name') != @get('model.formStructure.name')
        form
  ).property "model"

  jumpToForm: null

  jumpToFormObserver: (->
    if !Ember.isEmpty(@get('jumpToForm'))
      nextForm = @get('jumpToForm')
      subjectID = @get('model.subjectID')
      @set 'jumpToForm', null
      path = {}
      if nextForm.get('userPermissions.enterData')
        destination = "instance.edit"
        path = {
          path: "forms/:formID/responses/:subjectID/:instance/edit"
        }
      else
        destination = "instance"
        path = {
          path: "forms/:formID/responses/:subjectID/:instance"
        }
      @storage.loadFormResponse(nextForm, subjectID)
      .then (formResponse) =>
        unless @hasChanges()
          @transitionToRoute(destination, nextForm.get("id"), subjectID, -1)
          @focusFirst()
        else
          @set 'focusFirstAfterTrans', true
          @transitionToRoute(destination, nextForm.get("id"), subjectID, -1)
        #@setupDisplayedQuestions()
        #@setupQuestionSearchArray()

  ).observes('jumpToForm')
