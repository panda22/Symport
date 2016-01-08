LabCompass.FormResponse = LD.Model.extend
  id: null

  formStructure: LD.hasOne "formStructure", required: true, readOnly: true
  answers: LD.hasMany "formAnswer"
  subjectID: LD.attr "string"
  newSubject: LD.attr "boolean"
  updatedAt: LD.attr "date"

  instanceNumber: LD.attr "number"
  secondaryId: LD.attr()
  allInstances: []

  shortSecondaryId: (->
    str = @get("secondaryId") || ""
    length = str.length
    if length > 16
       str = str.substring(0, 14) + "..."
    else
      return str
  ).property("secondaryId")

  isDisplayed: false

  canDelete: false

  updateCanDelete: (->
    @set("canDelete", @isDisplayed and (@id != null))
  ).observes("isDisplayed", "id")

  selectedSecondaryId: null

  lastUpdatedString: ( ->
    cur = @get 'updatedAt'
    if Ember.isEmpty cur
      if @get("formStructure.isManyToOne")
        formSecondaryId = @get("formStructure.secondaryId")
        if @get("newSubject")
          "This is a new Subject ID and #{formSecondaryId} in this form"
        else
          "This is a new #{formSecondaryId} for this Subject ID"
      else
        "This is a new Subject ID in this form"
    else 
      "Last Saved at " + moment(cur).format "h:mm A [on] M/D/YYYY"
  ).property 'updatedAt'


  percentCompleted: ( ->
    answersCount = 0
    answerableQuestionsCount = 0
    @get('answers').toArray().forEach (answer) ->
      if answer.get('question.isAnswerable') && !answer.get('conditionallyDisabled')
        answerableQuestionsCount++
        if !Ember.isEmpty answer.get('answer') && answer.get('answer') != "\u200d"
          answersCount++
    Math.round(answersCount / answerableQuestionsCount * 100)
  ).property "answers"

  answerSorting: ["question.sequenceNumber"]
  sortedAnswers: Ember.computed.sort "answers", "answerSorting"


  questionNumberAndDependencyAssigner: (->
    questions = @get('sortedAnswers').mapBy('question')
    LabCompass.QuestionNumberAssigner(questions)
    LabCompass.DependentQuestionIdentifier(questions)
  ).observes("sortedAnswers.[]").on("init")

