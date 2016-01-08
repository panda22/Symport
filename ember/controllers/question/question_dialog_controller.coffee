LabCompass.QuestionDialogController = Ember.ObjectController.extend LabCompass.WithFormStructure,

  previewing: false

  form: (->
    if Ember.isEmpty(@get("formStructure"))
      @get("model.formStructure")
    else
      @get("formStructure")
  ).property "model"

  resizeQuestionBuilder: ->
    document.getElementById('question-builder-left-side').setAttribute("style","height: " + (window.innerHeight - 180) + "px")
    document.getElementById('question-builder-right-side').setAttribute("style","height: " + (window.innerHeight - 180) + "px")

  dialogScroller: ->
    scrollAmount = $(window).scrollTop()
    $(window).scrollTop(scrollAmount)

  dialogTapper: ->
    scrollAmount = $(window).scrollTop()   
    if $(window).scrollTop() + $(window).height() > $(document).height()
      $(window).scrollTop(scrollAmount)

  fullSizePopup: (->
    $(document).on 'opened', '[data-reveal]', =>
      document.getElementById('question-builder-left-side').setAttribute("style","height: " + (window.innerHeight - 180) + "px")
      document.getElementById('question-builder-right-side').setAttribute("style","height: " + (window.innerHeight - 180) + "px")
      document.getElementsByTagName("body")[0].style.overflowY = "hidden"
      yval = $(window).scrollY

      $(window).on('touchmove', @dialogScroller)
      $(window).on('swipe', @dialogScroller)
      $(window).on('scrollstop', @dialogScroller)
      $(window).on('scrollstart', @dialogScroller)
      $(window).on('tap', @dialogTapper)
      $(window).on('resize', @resizeQuestionBuilder)

      $(".conditionSelector").on 'focus', 'input, select', =>
        $(".conditionSelector")[0].parentElement.setAttribute("style", "background: #D4f4E4")
      $(".conditionSelector").on 'focusout', 'input, select', =>
        $(".conditionSelector")[0].parentElement.setAttribute("style", "background: none")    

    $(document).on 'closed', '[data-reveal]', =>
      document.getElementsByTagName("body")[0].style.overflowY = "auto"
      $(document).off 'opened'
      $(window).off('resize', @resizeQuestionBuilder)
      $(window).off('touchmove', @dialogScroller)
      $(window).off('swipe', @dialogScroller)
      $(window).off('scrollstart', @dialogScroller)
      $(window).off('scrollstop', @dialogScroller)
      $(window).off('tap', @dialogTapper)

  ).observes "window.innerHeight"

  questionErrorListener: (->
    if @get("hasErrors") == true
      @set("isLoading", false)
  ).observes("hasErrors")

  isLoading: false

  listenForIsLoading: (->
    @set("isLoading", false)
  ).observes "model"

  otherQuestions: ( ->
    @get('form.sortedQuestions').reject (question) =>
      question.get("id") == @get('model.id')
  ).property "form.sortedQuestions", 'model'

  isEditing: ( ->
    !@get("previewing")
  ).property "previewing"

  isNew: (->
    !@get("hasID")
  ).property "hasID"

  insertSample: (->
    type = @get("model.type")
    if @isChoiceType(type)
      answerChoices = @get("model.config.selections")
      if (answerChoices.content.length == 0)
        answerChoices.addObject {isNew: true}
        answerChoices.get("content")[0].set("code", "1")
        #Ember.run.next(=>
        #  $(".edit-question-code").val("1")
        #)
        @attachClassToSampleForTesting()
    Ember.run.next(=>
      $(".question-type").focus()
    )
  ).observes "model.type"

  styleOptionsWhenNoData: (->
    struct = @get 'form'
    hasData = struct.get('responsesCount') != 0
    
    for option in (@get('model.config.selections.content') || [])
      option.set('hasData', hasData)
      for question in struct.get('questions.content')
        for condition in question.get('conditions.content')
          if condition.get('value') == option.get('value') && condition.get('dependsOn') == @get('model.id')
            option.usedInCondition = true

    for exception in (@get('model.exceptions.content') || [])
      exception.set('hasData', hasData)
      e_type = exception.get("exceptionType")
      e_val = exception.get('value')
      for question in struct.get('questions.content')
        for condition in question.get('conditions.content')
          c_val = condition.get('value')
          if condition.get('dependsOn') == @get('model.id') && !Ember.isEmpty(c_val)
            if question.type != "date" && e_val == c_val 
              exception.usedInCondition = true
            else if e_type == "date_day" && e_val == c_val.slice(3,5)
              exception.usedInCondition = true
            else if e_type == "date_month" && e_val == c_val.slice(0,2)
              exception.usedInCondition = true
            else if e_type == "date_year" && e_val == c_val.slice(6,10)
              exception.usedInCondition = true

  ).observes('model.id')

  attachClassToSampleForTesting: ->
    window.setTimeout(->
      $(".option-value").addClass("sample-answer")
    , 300)

  isChoiceType: (type) ->
    switch type
      when "radio", "checkbox", "dropdown" then return true
      else return false

  actions:
    addCondition: ->
      @get('model.conditions').addObject(@storage.createModel('questionCondition'))
      Ember.run.next ->
        $(".select-condition-question:last").focus()
        $(".conditionSelector")[0].parentElement.setAttribute("style", "background: #D4f4E4")

    removeException: (exception)->
      @get("model.exceptions.content").removeObject exception

    addException: (e_type)->
      type = @get("model.type")
      i = -1
      found = i
      found_value = found_label = "\u200c"
      for exception in $('.exception-label')
        i = i + 1
        if $(exception).is(":focus")
          found = i
          if type =="date"
            found_value = exception.parentElement.parentElement.parentElement.children[0].children[1].value
            found_label = exception.parentElement.parentElement.parentElement.children[1].children[0].children[1].value
      if found == -1
        found = i

      if type != "date"
        exception = @get('model.exceptions').insertAt(found+1, {isNew: true, exceptionType: type})
      else
        if found_value == "\u200c"
          exception = @get('model.exceptions').insertAt(found+1, {isNew: true, exceptionType: e_type})
        else
          i = 0
          for exception in @get('model.exceptions.content')
            if exception.get('value') == found_value && exception.get('label') == found_label && exception.get('exceptionType') == e_type  
              exception = @get('model.exceptions').insertAt(i+1, {isNew: true, exceptionType: e_type})
              return
            i = i + 1


    sendSaveQuestion: (question) ->
      @send("loadingOn")
      question.set("hasErrors", false)
      $(".dialog button").each(->
        $(this).attr("disabled", true)
      )
      @send("saveQuestion", question)