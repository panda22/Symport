#answer-editor
#widgets for answers for any question type
#answer: a formAnswer model. Blank one for empty answer
#enabled: allows user input into the component
#qBuilderPreview: true if this is being used in the question edit modal
#editing: unused for this component, usually from question-editor indicating whether the question is being answered or edited
LabCompass.AnswerEditorComponent = Ember.Component.extend
  answer: null
  editing: true
  enabled: true
  conditionallyDisabled: Ember.computed.alias("answer.conditionallyDisabled")
  disabled: (->
    !@get("enabled") || @get("conditionallyDisabled")
  ).property('enabled',"conditionallyDisabled")

  showQuestionWhenConditionallyDisabled: false

  queryAnswer: false

  showObserver: (->
    @updateShowingConditionalContent()
  ).observes("showQuestionWhenConditionallyDisabled", "conditionallyDisabled")

  didInsertElement: ->
    @_super(arguments...)
    @updateShowingConditionalContent()
    @updateHeadingColors()
    @set("originalType", @get("answer.question.type"))
    @set("originalConfig", @get("answer.question.config"))
    @set("isValidFormat", false)
    @setInvalidFormat(false)

  updateShowingConditionalContent: (->
    show = !@get("conditionallyDisabled") || @get("showQuestionWhenConditionallyDisabled")
    content = @$(".conditionally-disabled-content")
    @$(".question-number-container").removeClass("empty-saved-heading filled-in-heading no-error-heading")
    if show
      content.animate(height: "show", opacity: "show")
    else
      content.animate(height: "hide", opacity: "hide")
  )

  valueChanged: (->
    @$(".question-number-container")
      .removeClass("empty-saved-heading filled-in-heading no-error-heading")
    $('#success-flash').addClass("hide")
  ).observes "answer.answer"

  updateHeadingColors: ->
    if @get('answer.id')
      if @get('answer.answer') == ""
        @$(".question-number-container")
          .addClass("empty-saved-heading no-error-heading")
      else
        @$(".question-number-container")
          .addClass("filled-in-heading no-error-heading")

  originalType: ""
  originalConfig: null
  isValidFormat: false
  setAnswerIsInvalid: (->
    @set("answer.isInvalid", !@get("isValidFormat"))
  ).observes("isValidFormat")

  setInvalidFormat: ( (setValid=true) ->
    if @get("qBuilderPreview") || @get("isValidFormat") || @get("queryAnswer")
      return
    val = @get("answer.answer")
    qType = @get("originalType")
    config = @get("originalConfig")
    if @isValidAnswerString(val, qType, config)
      isChange = (@get("answer.type") != qType)
      @set("answer.question.type", qType)
      @set("answer.question.config", config)
      @set("isValidFormat", true)
      if isChange
        Ember.run.scheduleOnce("afterRender", =>
          $textField = @$().find("input[type='text']")
          if $textField.length > 0
            $textField.focus()
            val = $textField.val()
            $textField.val(val)

        )
    else
      Ember.run.scheduleOnce("afterRender", =>
        @changeErrorMessage(@get("answer"), @get("answer.question.type"), config)
        @set("answer.question.type", "text")
        @set("answer.answer", val)
        @notifyPropertyChange("isValidFormat")
      )
  ).observes("answer.answer")

  actions:
    toggleDisplayWhenConditionallyDisabled: ->
      @toggleProperty("showQuestionWhenConditionallyDisabled")


  isValidAnswerString: (answerVal, questionType, config=null) ->
    if Ember.isEmpty(answerVal)
      return true
    switch (questionType)
      when "text"
        return true
      when "date"
        return !isNaN(Date.parse(answerVal))
      when "zipcode"
        return /(^\d{5}$)/.test(answerVal)
      when "checkbox"
        if config == null
          return false
        options = config.get("selections.content").mapBy("value")
        answerVal = @joinUserAnswers(answerVal, config)
        values = answerVal.split("\u200c")
        for value in values
          actualValue = value.split("\u200a")[0]
          if options.indexOf(actualValue) == -1
            return false
        @set("answer.answer", answerVal)
        return true
      when "radio", "dropdown"
        if config == null
          return false
        options = config.get("selections.content").mapBy("value")
        #answerVal = @joinUserAnswers(answerVal, config)
        actualValue = answerVal.split("\u200a")[0]
        if options.indexOf(actualValue) == -1
          return false
        else
          @set("answer.answer", answerVal)
          return true
      when "email"
        return /\S+@\S+\.\S+/.test(answerVal)
      when "yesno"
        downcaseAnswer = answerVal.toLowerCase()
        if downcaseAnswer == "yes" or downcaseAnswer == "no"
          return true
        else
          return false
      when "timeofday"
        return /^([0-9]|0[0-9]|1[0-2]):[0-5][0-9] (AM|PM)$/.test(answerVal)
      when "timeduration"
        return /^\d+:\d+:\d+$/.test(answerVal)
      when "numericalrange"
        /^[-]?\d+(\.\d+)?$/.test(answerVal)
      when "phonenumber"
        /^(\d{3}|\(\d{3}\))-(\d{3})-(\d{4})(?:x(\d+))?$/.test(answerVal)
      when "header"
        return true
      else
        console.error "unrecognized type: " + questionType
        return false



  joinUserAnswers: (answerVal, config) ->
    answers = answerVal.split("\n")
    for option in config.get("selections.content")
      if option.get("otherOption")
        @set("answer.hasInvalidOther", true)
        @set("answer.invalidOtherVariableName", option.get("otherVariableName"))
        answerIndex = answers.indexOf(option.get("value"))
        if answerIndex != -1
          answers[answerIndex] += ("\u200a" + @get("answer.tempOtherVal"))
    retVal = answers.join("\u200c")
    return retVal


  changeErrorMessage: (answer, questionType, config) ->
    newMessage = @getNewErrorMessages(questionType, config)
    if newMessage
      answer.set("errorMessage", newMessage)
    return

  getNewErrorMessages: (qType, config) ->
    switch qType
      when "date"
        return "Please enter a date in the format mm/dd/yyyy."
      when "zipcode"
        return "Please enter a Zip Code, it must be exactly 5 numeric characters. (i.e 48103)"
      when "checkbox"
        @set("answer.displayInvalidOptions", true)
        @set("answer.tempConfig", config)
        if @get("answer.hasInvalidOther")
          return ("Some answers may be incomplete or spelled incorrectly. " +
          "Checkbox answers must match the choices " +
          "listed below and must be entered on a new line. " +
          @getOtherMessage())
        else
          return ("Some answers may be incomplete or spelled incorrectly. " +
              "Checkbox answers must match the choices " +
              "listed below and must be entered on a new line. ")
      when "radio"
        @set("answer.displayInvalidOptions", true)
        @set("answer.tempConfig", config)
        if @get("answer.hasInvalidOther")
          return "Some answers may be incomplete or spelled incorrectly. Answers must match the choices listed below and must be entered on a new line. " +
              @getOtherMessage()
        else
          return "Some answers may be incomplete or spelled incorrectly. Answers must match the question's answer choices listed below."
      when "dropdown"
        @set("answer.displayInvalidOptions", true)
        @set("answer.tempConfig", config)
        return "Some answers may be incomplete or spelled wrong. Dropdown answers must match the question's answer choices listed below."
      when "yesno"
        return "Answers must be yes or no. Please be sure they are spelled correctly."
      when "timeofday"
        return "Please enter a time of day in the format HH:MM AM/PM. Be sure to include the space between AM/PM and HH:MM."
      when "timeduration"
        return "Please enter a time duration in the format DD:HH:MM."
      when "phonenumber"
        return "Please enter a phone number in the format ###-###-####(x#~#)"
      when "numericalrange"
        return @getNumericalRangeMessage()
      else return null

  getNumericalRangeMessage: ->
    message = "Numbers cannot contain letters or special characters. "
    config = @get("answer.question.config")
    str = ""
    prec = config.get('precision')
    no_min = Ember.isEmpty(config.get('minValue'))
    no_max = Ember.isEmpty(config.get('maxValue'))

    if prec == 0
      str = "Enter a whole number"
    else if prec == 6
      str = "Enter any number"
    else if prec == 1
      str = "Enter a number with at least " + prec + " decimal place"
    else
      str = "Enter a number with at least " + prec + " decimal places"

    if no_min && no_max
      str = str
    else if no_min
      str = str + " that is less than #{config.get('minValue')}"
    else if no_max
      str = str + " that is greater than #{config.get('maxValue')}"
    else
      str = str + " that is between #{config.get('minValue')} and #{config.get('maxValue')}"

    return message + str

  getOtherMessage: ->
    message = " Please enter the text for "
    config = @get("answer.question.config")
    found = false
    for option in config.get("selections.content")
      if option.get("otherOption")
        found = true
        varName = option.get("otherVariableName")
        value = option.get("value")
        message += "#{value} in the #{varName} textbox"
    if found
      return message
    else
      return ""





  # WE DON'T ACTUALLY WANT THIS, THOUGH IT LOOKS WEIRD TO NOT CLEAR THE ANSWER
  # clearAnswerOnConditionallyDisabled: (->
  #   if @get("conditionallyDisabled")
  #     @set("answer.answer", "")
  # ).observes("conditionallyDisabled")
