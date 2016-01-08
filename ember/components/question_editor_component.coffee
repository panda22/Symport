#question-editor
#widget for questions in qform builder
#will display full content for editing a question
# OR
#will display basic question information as a disabled answer-editor with a fake FormAnswer model
#editing: true for question editing content OR false for disabled answer-editor 
#question: the FormQuestion model
#isNew: is this a new question or dediting an existing question? if true then all fields will be editable. If false, certain fields will be disabled
#otherQuestions: otherQuestions in form, usually from question_dialog_controller
LabCompass.QuestionEditorComponent = Ember.Component.extend
  question: null
  addConditionAction: "addCondition"
  removeConditionAction: "removeCondition"
  addExceptionAction: "addException"
  removeExceptionAction: "removeException"

  disableBackspace: (e) ->
    if e.which == 8 && !$(e.target).is('input, textarea')
      e.preventDefault()

  didInsertElement: ->
    $(document).on('keydown', @disableBackspace)
    @recomputeDateLists()
    t = @get 'question.type'

    if t == "timeofday"
      @set 'help', "Use the button Add Code below to allow for the entry of 99:99 etc. into answer fields."
      @set 'ie_text', "A. Set Code(i.e 99:99)"
    else
      @set 'help', "Use the button Add Code below to allow for the entry of 999,888,777 etc. into answer fields."
      @set 'ie_text', "A. Set Code(i.e 9999)"

  willDestroyElement: ->
    $(document).off('keydown', @disableBackspace)

  questionTypes: ( ->
    LabCompass.QuestionTypes.get("questionTypes")
  ).property()

  fakeAnswer: ( ->
    @container.lookup("storage:main").createModel "formAnswer", question: @get("question")
  ).property "question.type"

  typeInfo: ( ->
    @get("questionTypes").findBy "type", @get("question.type")
  ).property "question.type"

  typeName: ( ->
    @get("typeInfo").name
  ).property "typeInfo"

  typeHint: ( ->
    @get("typeInfo").hint
  ).property "typeInfo"

  isHeaderType: ( ->
    if @get("question.type") == "header"
      true
    else
      false
  ).property "question.type"

  regularExceptions: ( ->
    t = @get "question.type"
    if t == "zipcode" || t == "numericalrange" || t == "email" || t == "timeofday"
      true
    else
      false
  ).property("question.type")

  clearExceptions: ( ->
    @set('question.exceptions', [])
    t = @get 'question.type'
    if t == "header"
      @set "question.variableName", ""
    else if t == "timeofday"
      @set 'help', "Use the button Add Code below to allow for the entry of 99:99 etc. into answer fields."
      @set 'ie_text', "A. Set Code(i.e 99:99)"
    else
      @set 'help', "Use the button Add Code below to allow for the entry of 999,888,777 etc. into answer fields."
      @set 'ie_text', "A. Set Code(i.e 9999)"
  ).observes("question.type")

  help: ""
  ie_text: ""

  dateException: ( ->
    t = @get "question.type"
    if t == "date"
      true
    else
      false
  ).property("question.type")

  dayExceptions: []
  monthExceptions: []
  yearExceptions: []
  recomputeDateLists: ->
    if @get('question.type') != "date"
      return
    d = []
    m = []
    y = []
    for exception in @get('question.exceptions.content')
      if exception.get('exceptionType') == "date_year"
        y.push exception
      if exception.get('exceptionType') == "date_month"
        m.push exception
      if exception.get('exceptionType') == "date_day"
        d.push exception
    @set 'dayExceptions', d
    @set 'monthExceptions', m
    @set 'yearExceptions', y


  setQuestionNumber: (->
    if @get('question') && @get('editing')
      @set('question.questionNumber', @get('previousAnswerableQuestions.length') + 1)
  ).observes("previousAnswerableQuestions", 'question.sequenceNumber').on "init"

  previousAnswerableQuestions: ( ->
    otherQuestions = @get('otherQuestions') || []

    otherQuestions.reject( (question) =>
      isFormatting = LabCompass.QuestionTypes.isFormattingType(question.get('type')) ||
        (question.get('sequenceNumber') >= @get('question.sequenceNumber'))
    )
  ).property "otherQuestions", "otherQuestions.@each.type", "question.sequenceNumber"

  actions:
    addCondition: ->
      @sendAction "addConditionAction"

    addException: (type)->
      i = -1
      found = i
      never_found = false
      for val in $('.exception-label')
        i = i + 1
        if $(val).is(":focus")
          found = i
      if found == -1
        found = i
        never_found = true

    removeConditionAction: (cond) ->
      @get('question.conditions').removeObject(cond)

      @sendAction "addExceptionAction", type
      @recomputeDateLists()
      Ember.run.next =>
          if type == "date_year" && never_found
            $(".year-exception-value:last").focus()
          else if type == "date_month" && never_found
            $(".month-exception-value:last").focus()
          else if type == "date_day" && never_found
            $(".day-exception-value:last").focus()
          else
            $(@$().find(".exception-value")[found+1]).focus()

   
    addYearException: ->
      @send "addException", "date_year"
    addMonthException: ->
      @send "addException", "date_month"
    addDayException: ->
      @send "addException", "date_day"

    removeException: (exception)->
      scrollTop = $("#question-builder-left-side").scrollTop()
      @sendAction "removeExceptionAction", exception
      Ember.run.next =>
        @recomputeDateLists()
        $("question-builder-left-side").scrollTop(scrollTop)