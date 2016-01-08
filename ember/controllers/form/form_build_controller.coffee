LabCompass.FormBuildController = Ember.ObjectController.extend LabCompass.WithProject,

  breadCrumb: "Build Form - Edit Form"
  
  hasAnyData: (->
    @get('model.responsesCount') != 0
  ).property 'model.responseCount'

  QUESTIONS_PER_PAGE: 25

  isPaging: false

  setIsPaging: (->
    if @get("model.sortedQuestions.length") > @QUESTIONS_PER_PAGE
      @set("isPaging", true)
    else
      @set("isPaging", false)
  ).observes("model.sortedQuestions.length")

  isFirstPage: true
  prevPageQuestion: null
  newPagePrevQuestion: null

  addNewPage: false
  isNewPage: false

  displayedQuestions: Ember.A([])

  paginatedQuestions: Ember.ArrayProxy.create({content: Ember.A([])})

  paginationInfo: {
    lastQuestionName: "",
    pages: Ember.A([]),
    firstPage: null,
    lastPage: null
  }

  curPageInfo: Ember.Object.create({
    firstQuestionName: "",
    lastQuestionName: "",
    index: 0,
    questionIndex: 0,
    isCurPage: true
  })

  initialButtonText: false

  positionTooltip2: ->
    Ember.run.later(->
      topCount = Number($(".xlarge.question-editor-modal").css("top").substring(0,2))
      topCount = topCount + $($(".question-builder-field")[0]).height() + $($(".question-builder-field")[1]).height() + $($(".question-builder-field")[2]).height() + $($(".question-builder-field")[3]).height() + $($(".question-builder-field")[4]).height()+ (($($(".question-builder-field")[5]).height())/2) + 50
      $(".formBuilderJoyride2").css("top", topCount + "px")
    , 200)

  positionTooltip3: ->
    Ember.run.later(->
      topCount = Number($(".xlarge.question-editor-modal").css("top").substring(0,2))
      topCount = topCount + $($(".question-builder-field")[0]).height() + $($(".question-builder-field")[1]).height() + $($(".question-builder-field")[2]).height() + $($(".question-builder-field")[3]).height() + $($(".question-builder-field")[4]).height() + $($(".question-builder-field")[5]).height() + (($($(".question-builder-field")[6]).height())/2) + 75
      $(".formBuilderJoyride3").css("top", topCount + "px")
    , 200)


  changeTeamIcon: ->
    myModel = @get('project')
    $(".team-icon").on 'click', =>
      myModel.set("demoProgress.teamButton", true)
      $(".team-icon").addClass("active")
      $(".team-icon").removeClass("animated pulse infinite")
      $(".team-icon").css("box-shadow", "none")
    if myModel.get("demoProgress.teamButton") == true || myModel.get("isDemo") == false
      $(".team-icon").removeClass("active")
    else
      window.setTimeout(=>
        if $(".team-icon.teamText").hasClass("active")
          $(".team-icon").removeClass("active")
        else
          $(".team-icon").addClass("active")
        @changeTeamIcon()
      , 500)

  changeImportIcon: ->
    myModel = @get('project')
    $(".import-icon").on 'click', =>
      myModel.set("demoProgress.importButton", true)
      $(".import-icon").addClass("active")
      $(".import-icon").removeClass("animated pulse infinite")
      $(".import-icon").css("box-shadow", "none")
    if myModel.get("demoProgress.importButton") == true || myModel.get("isDemo") == false
      $(".import-icon").removeClass("active")
    else
      window.setTimeout(=>
        if $(".import-icon").hasClass("active")
          $(".import-icon").removeClass("active")
        else
          $(".import-icon").addClass("active")
        @changeImportIcon()
      , 500)


  scrollValue: 0
  scrollValueWatcher: (->
    $("#questionBuilderJoyride").foundation({
          joyride : {
               scroll_speed: @get("scrollValue")
          }
      });
  ).observes("scrollValue")


  checkForQuestionBuilder: ->
    popup = $(".question-editor-modal")
    myModel = @get('project')
    if popup.length > 0
      #hacky solution to get the joyride to stop arbitrarily scrolling, a scroll_speed
      #of 0 makes it jump so the larger the number the more drawn out it is
      #with a number this large, the session would time out way before the speed
      #even will move at all for the user to notice
      @set("scrollValue", 3600000)
      #$($(".question-builder-field")[1]).attr("id", "questionBuilderJoyride1")
      #$($(".question-builder-field")[4]).attr("id", "questionBuilderJoyride2")
      #$($(".question-builder-field")[5]).attr("id", "questionBuilderJoyride3")
      $("#questionBuilderJoyride").foundation('joyride', 'off')
      $("#questionBuilderJoyride").foundation('joyride', 'start')



      $(window).on 'closed', =>
        $("#buildFormJoyride").foundation('joyride', 'hide')
        @set("scrollValue", 0)
        $("#questionBuilderJoyride").foundation('joyride', 'off')
        $("#questionBuilderJoyride").foundation('joyride', 'start')
        $("#questionBuilderJoyride").foundation('joyride', 'hide')
        Ember.run.later(=>
          $("*").stop()
          $("*").stop()
          $("*").stop()
          if myModel.get("demoProgress.formGlobal") == true
            if myModel.get("demoProgress.addTeamMemberProgress") == false
              @changeTeamIcon()
              $(".team-icon").addClass("animated pulse infinite")
              $(".team-icon").css("box-shadow", "0px 0px 0px 3px #cccccc")
              $(".team-icon").on 'click', =>
                $(".team-icon").removeClass("animated pulse infinite")
                $(".team-icon").css("box-shadow", "none")
                myModel.set("demoProgress.teamButton", true)
                @storage.updateDemoProgress(@get("id"), @get("demoProgress"))
                
            if myModel.get("demoProgress.importProgress") == false
              @changeImportIcon()
              $(".import-icon").addClass("animated pulse infinite")
              $(".import-icon").css("box-shadow", "0px 0px 0px 3px #cccccc")
              $(".import-icon").on 'click', =>
                $(".import-icon").removeClass("animated pulse infinite")
                $(".import-icon").css("box-shadow", "none")
                myModel.set("demoProgress.importButton", true)
                @storage.updateDemoProgress(@get("id"), @get("demoProgress"))
        , 500)


    

      if myModel.get("demoProgress.questionBuilderPrompt") == false
        $($(".joyride-next-tip")[0]).on 'click', =>
          myModel.set("demoProgress.questionBuilderPrompt", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
          $($(".joyride-next-tip")[1]).on 'click', =>
            myModel.set("demoProgress.questionBuilderVariable", true)
            @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
            $(".button.main.right").addClass("animated pulse infinite")
            $(".button.main.right").on 'click', =>
              $(".button.main.right").removeClass("animated pulse infinite")
              myModel.set("demoProgress.questionBuilderIdentifying", true)
              myModel.set("demoProgress.buildFormButton", true)
              myModel.set("demoProgress.formBuilderInfo", true)
              myModel.set("demoProgress.buildFormAddQuestion", true)
              @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
              if myModel.get("demoProgress.displayHelpTooltip") == true
                Ember.run.later(=>
                  $("#helpJoyride").foundation("joyride", "off")
                  $("#helpJoyride").foundation("joyride", "start")
                  $(".joyride-close-tip").remove()
                  $($(".joyride-next-tip")[1]).on 'click', =>
                    @transitionToRoute "index"
                , 2000)
      else if myModel.get("demoProgress.questionBuilderVariable") == false
        $($(".joyride-next-tip")[0]).trigger('click')
        $($(".joyride-next-tip")[1]).on 'click', =>
          myModel.set("demoProgress.questionBuilderVariable", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
          $(".button.main.right").addClass("animated pulse infinite")
          $(".button.main.right").on 'click', =>
            $(".button.main.right").removeClass("animated pulse infinite")
            myModel.set("demoProgress.questionBuilderIdentifying", true)
            myModel.set("demoProgress.buildFormButton", true)
            myModel.set("demoProgress.formBuilderInfo", true)
            myModel.set("demoProgress.buildFormAddQuestion", true)
            @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
            if myModel.get("demoProgress.displayHelpTooltip") == true
              Ember.run.later(=>
                $("#helpJoyride").foundation("joyride", "off")
                $("#helpJoyride").foundation("joyride", "start")
                $(".joyride-close-tip").remove()
                $($(".joyride-next-tip")[1]).on 'click', =>
                  @transitionToRoute "index"
              , 2000)
      else if myModel.get("demoProgress.questionBuilderIdentifying") == false
        $($(".joyride-next-tip")[0]).trigger('click')
        $($(".joyride-next-tip")[1]).trigger('click')
        $(".button.main.right").addClass("animated pulse infinite")
        $(".button.main.right").on 'click', =>
          $(".button.main.right").removeClass("animated pulse infinite")
          myModel.set("demoProgress.questionBuilderIdentifying", true)
          myModel.set("demoProgress.buildFormButton", true)
          myModel.set("demoProgress.formBuilderInfo", true)
          myModel.set("demoProgress.buildFormAddQuestion", true)
          @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
          if myModel.get("demoProgress.displayHelpTooltip") == true
            Ember.run.later(=>
              $("#helpJoyride").foundation("joyride", "off")
              $("#helpJoyride").foundation("joyride", "start")
              $(".joyride-close-tip").remove()
              $($(".joyride-next-tip")[1]).on 'click', =>
                @transitionToRoute "index"
            , 2000)
    else
      window.setTimeout(=>
        @checkForQuestionBuilder()
      , 800)

      
  handleDemoProgress: ->
    myModel = @get('project')
    if myModel.get("isDemo") == true && (myModel.get("demoProgress.demoFormId") == @get("id")) && myModel.get("demoProgress.initialOnboarding") == true && myModel.get("demoProgress.buildFormProgress") == false

      Ember.run.next(=>
        $($(".button.light-plus-with-text.right")[0]).attr("id", "addAQuestion")

        $("#buildFormJoyride").foundation({
            joyride : {
                 scroll_speed: 0
            }
        });

        $("#buildFormJoyride").foundation("joyride", "off")
        $("#buildFormJoyride").foundation("joyride", "start")
        $(".joyride-close-tip").remove()
        $($(".joyride-next-tip")[1]).css("visibility", "hidden")
        $("#addAQuestion").on 'click', =>
          $($(".joyride-next-tip")[1]).trigger('click')
          @checkForQuestionBuilder()
      )

  setupDisplayedQuestions: (curPage=null) ->
    if curPage == null
      curPage = @get("model.curPage")
    if @get("model.sortedQuestions.length") == 0
      @set("displayedQuestions", Ember.A([]))
      return
    @set("curSearchString", "")
    allQuestions = @get("model.sortedQuestions")
    if curPage == 0
      @set("isFirstPage", true)
    else
      @set("isFirstPage", false)
    @set("isNewPage", false)
    @set("model.curPage", curPage)
    start = curPage * @QUESTIONS_PER_PAGE
    @set("paginatedQuestions", Ember.A([]))
    @get("paginatedQuestions").pushObjects(allQuestions.slice(start, start + @QUESTIONS_PER_PAGE))
    if allQuestions.length != 0
      @set("prevPageQuestion", allQuestions[start - 1])
      @set("newPagePrevQuestion", allQuestions[allQuestions.length - 1])
    @set("displayedQuestions", @get("paginatedQuestions"))
    @setupPaginationInfo()

  setupPaginationInfo: ->
    allQuestions = @get("model.sortedQuestions")
    numQuestions = allQuestions.length
    lastQuestionName = allQuestions[numQuestions - 1].get("sequenceNumber")
    pages = Ember.A([])
    questionIndex = 0
    index = 0
    firstPage = null
    lastPage = null
    while questionIndex < numQuestions
      pageObj = Ember.Object.create({})
      pageObj.set("index", index)
      pageObj.set("questionIndex", questionIndex)
      pageObj.set("isCurPage", if (index == @get("model.curPage")) then true else false)
      pageObj.set("firstQuestionName", allQuestions[questionIndex].get("sequenceNumber"))
      lastIndex = Math.min(numQuestions - 1, questionIndex + @QUESTIONS_PER_PAGE - 1)
      pageObj.set("lastQuestionName", allQuestions[lastIndex].get("sequenceNumber"))
      pages.pushObject(pageObj)
      if firstPage == null
        firstPage = pageObj
      if pageObj.isCurPage == true
        @set("curPageInfo", pageObj)
      questionIndex += if (@QUESTIONS_PER_PAGE > 0) then @QUESTIONS_PER_PAGE else 1
      if questionIndex >= numQuestions
        lastPage = pageObj
      index += 1
    returnObj = {
      lastQuestionName: lastQuestionName,
      pages: pages,
      firstPage: firstPage,
      lastPage: lastPage
    }
    @set("paginationInfo", returnObj)
    @addLogicForAddPage()


  addLogicForAddPage: ->
    numQuestions = @get("model.sortedQuestions.length")
    isLastPage = (@get("model.curPage") == Math.floor((numQuestions - 1) / @QUESTIONS_PER_PAGE))
    if isLastPage and (numQuestions % @QUESTIONS_PER_PAGE == 0)
      @set("addNewPage", true)
      Ember.run.next(->
        $(".add-question-button-row:last").addClass("hide")
      )
    else
      @set("addNewPage", false)



  listenForChangeInDisplayedQuestions: (->
    if @get("model.sortedQuestions") == null
      @set("displayedQuestions", Ember.A([]))
      return
    @setupDisplayedQuestions()
  ).observes("model.sortedQuestions")

  findPageByQuestion: (question) ->
    seqNum = question.get("sequenceNumber")
    return Math.floor((seqNum - 1) / @QUESTIONS_PER_PAGE)

  questionSearchArray: Ember.A([])

  setupQuestionSearchArray: (->
    if @get("model.sortedQuestions") == null
      @set("questionSearchArray", Ember.A([]))
      return
    arr = Ember.A([])
    @set("questionSearchArray", arr)
    for question in @get("model.sortedQuestions")
      #if question.get("type") == "header"
      #  continue
      displayName = question.get("displayName")
      varName = question.get("variableName")
      if varName == ""
        arr.push("\u200b#{displayName}\u200b")
      else
        arr.push("#{displayName} \u200a[#{varName}]\u200a")
    @set("questionSearchArray", arr)
  ).observes("model.sortedQuestions")

  curSearchString: ""

  searchForQuestion: (->
    if @get("curSearchString") == null or @get("curSearchString") == ""
      return
    varName = ""
    isVarNameSearch = true
    if (@get("curSearchString").indexOf("\u200a") != -1) #search for variable name
      varName = @get("curSearchString").split("\u200a")[1].slice(1, -1)
    else if (@get("curSearchString").indexOf("\u200b") != -1) # search for display name (header type)
      isVarNameSearch = false
      varName = @get("curSearchString").split("\u200b")[1]
    if varName != ""
      target = null
      for question in @get("model.sortedQuestions")
        if isVarNameSearch and question.get("variableName") == varName
          target = question
          break
        if !isVarNameSearch and question.get("displayName") == varName
          target = question
          break
      if target != null
        newPage = @findPageByQuestion(target)
        @set("questionSaveSuccess", true)
        if newPage != @get("curPage")
          @setupDisplayedQuestions(@findPageByQuestion(target))
          @setupQuestionChangedAnimation(target, false)
        else
          @set("curSearchString", "")
          @setupQuestionChangedAnimation(target, false)
  ).observes("curSearchString")

  nextSequenceNumber: ->
    lastSequenceNumber = if @get('sortedQuestions').length
      @get('sortedQuestions.lastObject.sequenceNumber')+1
    else
      1
    lastSequenceNumber

  savedAtString: ""

  updateSavedAtString: ( ->
    date = new Date(@get("model.lastEdited"))
    if date == null
      @set("savedAtString", "")
      return
    formattedDate = @formatDateStringForSaved(date)
    retString =
      "All questions and changes automatically saved at " +
        formattedDate.hour + ":" + formattedDate.minute +
        " " + formattedDate.twelveHour + " on " +
        formattedDate.month + " " + formattedDate.day + ", " + formattedDate.year
    @set("savedAtString", retString)
  ).observes("model.lastEdited")

  formatDateStringForSaved: (dateObj) ->
    hour = ("0" + dateObj.getHours()).slice(-2)
    twelveHour = "AM"
    if hour > 12
      twelveHour = "PM"
      hour -= 12
    retObj = {}
    retObj.hour = hour
    retObj.minute = ("0" + dateObj.getMinutes()).slice(-2)
    retObj.second = ("0" + dateObj.getSeconds()).slice(-2)
    retObj.twelveHour = twelveHour
    retObj.day = dateObj.getDate()
    retObj.month = @monthNumber2String(dateObj.getMonth())
    retObj.year = dateObj.getFullYear()
    retObj

  questionSaveSuccess: false

  monthNumber2String: (monthNum) ->
    switch monthNum
      when 0 then return "January"
      when 1 then return "February"
      when 2 then return "March"
      when 3 then return "April"
      when 4 then return "May"
      when 5 then return "June"
      when 6 then return "July"
      when 7 then return "August"
      when 8 then return "September"
      when 9 then return "October"
      when 10 then return "November"
      when 11 then return "December"
      else return "January"

  setupQuestionChangedAnimation: (question, doAnimation=true) ->
    _this_ = @;
    window.setTimeout( ->
      Ember.run.next(->
        if (_this_.get("questionSaveSuccess") == true)
          answerBoxDiv = $("#" + question.get('id')).find(".form-answer-box")
          if answerBoxDiv.length == 0
            answerBoxDiv = $("#" + question.get('id')).find(".header")
          if doAnimation
            $("html, body").bind("scroll mousedown DOMMouseScroll mousewheel keyup", ->
              $('html, body').stop()
            )
            answerBoxDiv.addClass("with-green-shadow")
          else
            answerBoxDiv.addClass("with-gray-shadow")
          curPos =  $('body').scrollTop()
          newPos = answerBoxDiv.offset().top
          bottomMargin = parseInt($(window).height()) - answerBoxDiv.height()
          target = answerBoxDiv.offset().top - (parseInt($(window).height()) / 2)
          shouldMove = ((curPos + bottomMargin - newPos) < 0 or (newPos - curPos) < 0)
          window.setTimeout(->
            if doAnimation
              answerBoxDiv.removeClass("with-green-shadow")
            else
              answerBoxDiv.removeClass("with-gray-shadow")
          , 2000)
          if shouldMove
            if (doAnimation)
              $('html, body').animate({
                scrollTop: target
              }, 1000)
            else
              $('html, body').scrollTop(target)
          _this_.set("questionSaveSuccess", false)
      )
    , 1000)

  changeRangesAlertString: (question)->
    old_config = null
    for q in @get('model.questions.content')
      if q.get('id') == question.get('id')
        old_config = q.get('config')
    new_config = question.get('config')
    message = ""
    if old_config == null
      return ""
    if old_config.get('minValue') != new_config.get('minValue')
      message += "Min Value:  " + (old_config.get('minValue') || "'none'") + ' → ' + (new_config.get('minValue') || "'none'") + "\n"
    if old_config.get('maxValue') != new_config.get('maxValue')
      message += "Max Value:  " + (old_config.get('maxValue') || "'none'") + ' → ' + (new_config.get('maxValue') || "'none'") + "\n"
    precisionValues = ['Whole numbers only','0.1','0.01','0.001','0.0001','0.00001','Any number of decimal places']
    if old_config.get('precision') != new_config.get('precision')
      message += "Precision:  " + precisionValues[old_config.get('precision')] + ' → ' + precisionValues[new_config.get('precision')] + "\n"

    if message != "" 
      message = "Are you sure you wish to edit the following numerical range values?\n\n" + message
      message += "\nExisting data may be out of range when you try to save a form response"
    return message

  changeOptionsAlertString: (question)->
    old_config = null
    for q in @get('model.questions.content')
      if q.get('id') == question.get('id')
        old_config = q.get('config.selections.content')
    new_config = question.get('config.selections.content')
    message = ""
    if old_config == null
      return ""
    for old_option in (old_config || [])
      for new_option in new_config
        if old_option.get('id') == new_option.get('id')
          if old_option.get('value') != new_option.get('value')
            message += old_option.get('value') + '→' + new_option.get('value') + '\n'
         
    if message != ""
      message = "Are you sure you wish to edit the following answer choices?\n\n" + message
      message += "\nEdits to your answer choices will be reflected in the existing data, conditions, and query params."
    return message

  changeExceptionsAlertString: (question)->
    old_exceptions = null
    for q in @get('model.questions.content')
      if q.get('id') == question.get('id')
        old_exceptions = q.get('exceptions.content')
    new_exceptions = question.get('exceptions.content')
    message = ""
    if old_exceptions == null
      return ""
    for old_exception in (old_exceptions || [])
      for new_exception in new_exceptions
        if old_exception.get('id') == new_exception.get('id')
          if old_exception.get('value') != new_exception.get('value')
            message += old_exception.get('value') + '→' + new_exception.get('value') + '\n'
         
    if message != ""
      message = "Are you sure you wish to edit the following codes for missing values?\n\n" + message
      message += "\nEdits to your codes will be reflected in the existing data, conditions, and query params."
    return message

  getPrevQuestionID: (question) ->
    pos = question.get("sequenceNumber") - 1
    if pos == 0
      return null
    found = false
    for tempQuestion, i in @get("model.sortedQuestions")
      prompt = tempQuestion.get("prompt")
      if tempQuestion.id == question.id
        found = true;
        if tempQuestion.get("sequenceNumber") >= question.get("sequenceNumber")
          pos -= 1
    if found == false
      pos -= 1
    return @get("model.sortedQuestions")[pos].id

  predictNextDisplayNumber: (prevQuestion) ->
    prevDisplayNumber = prevQuestion.get("displayNumber")
    if isNaN(parseInt(prevDisplayNumber))
      return prevQuestion.get("sequenceNumber") + 1
    else
      parseInt(prevDisplayNumber) + 1
      return parseInt(prevDisplayNumber) + 1


  actions:
    changePage: (pageInfo) ->
      @setupDisplayedQuestions(pageInfo.get("index"))
      if @get("displayedQuestions.length") < @QUESTIONS_PER_PAGE
        @set("isPaging", false)
      Ember.run.next(->
        $("body").scrollTop(0)
      )

    addNewPage: ->
      @set("isNewPage", true)
      @set("addNewPage", false)
      @set("isPaging", true)
      Ember.run.next(->
        $(".paginate_button").removeClass("current")
      )

    addQuestion: ->
      newQuestion = @storage.createModel "formQuestion",
        questionNumber: 0
        sequenceNumber: 1
        displayNumber: 1
      @send "openDialog", "question", newQuestion, "questionDialog"

    addQuestionAfter: (question) ->
      if !question
        question = @get("sortedQuestions")[@get("sortedQuestions.length") - 1]
      newQuestion = @storage.createModel "formQuestion",
        questionNumber: question.get("sequenceNumber")
        sequenceNumber: (question.get("sequenceNumber") + 1)
        displayNumber: @predictNextDisplayNumber(question)
      #ques = question
      #Ember.run.next(=>
      #  if isNaN(newQuestion.get("sequenceNumber"))
      #    @set("newQuestion.sequenceNumber", @get("model.sortedQuestions.length") + 1)
      #)
      @send "openDialog", "question", newQuestion, "questionDialog"

    editQuestion: (question) ->
      @send "openDialog", "question", question.copy(), "questionDialog"

    duplicateQuestion: (question) ->
      newQuestion = question.copy()
      newQuestion.set 'id', null
      newQuestion.set 'sequenceNumber', (question.get("sequenceNumber") + 1)
      newQuestion.set("displayNumber", @predictNextDisplayNumber(question))
      options = newQuestion.get('config.selections.content')
      if !Ember.isEmpty options
        for option in options
          option.set('isNew', true)
      @send "openDialog", "question", newQuestion, "questionDialog"


    branchQuestion: (question) ->
      newQuestion = @storage.createModel "formQuestion",
        questionNumber: 0
        sequenceNumber: question.get("sequenceNumber") + 1
        displayNumber: @predictNextDisplayNumber(question)
        conditions: [
          dependsOn: question.get('id')
        ]
      @send "openDialog", "question", newQuestion, "questionDialog"
      $(document).on 'opened', '[data-reveal]', =>
        $(".conditionSelector").on 'focus', 'input, select', =>
          $(".conditionSelector")[0].parentElement.setAttribute("style", "background: #D4f4E4")
        
        $(".conditionSelector").on 'focusout', 'input, select', =>
          $(".conditionSelector")[0].parentElement.setAttribute("style", "background: none")
        
        Ember.run.next ->
          $(".select-condition-question:last").focus()

        $(document).off 'opened'


    confirmDeleteQuestion: (question) ->
      @send "openDialog", "confirm_delete_question", question

    deleteQuestion: (question) ->
      @updateSavedAtString()
      @send "closeDialog"

      qId = question.get('id')
      $("#" + qId).fadeOut(1000, "linear")

      scrollAmount = $(window).scrollTop()
      window.setTimeout =>
        @storage.deleteQuestion @get("model"), question
        .then =>
          curPage = @get("model.curPage")
          if curPage > (@get("sortedQuestions.length") - 1) / @QUESTIONS_PER_PAGE and curPage != 0
            curPage  -= 1
          @setupDisplayedQuestions(curPage)
          @setupQuestionSearchArray()
          Ember.run.next =>
            $(window).scrollTop(scrollAmount)
      , 1000

    saveQuestion: (question) ->
      _this_ = @
      if @get('hasAnyData')
        alert_message = ""
        type = question.get('type')
        if (type == "radio" || type == "checkbox" || type == "dropdown" )
          alert_message = @changeOptionsAlertString(question)
        else if type == "numericalrange"
          alert_message = @changeRangesAlertString(question)

        exceptions_alert_message = @changeExceptionsAlertString(question)
        if exceptions_alert_message != ""
          alert_message = alert_message + "\n\n\n" + exceptions_alert_message

        if alert_message != ""
          unless confirm(alert_message)
            Ember.run.next( ->
              question.set("hasErrors", true)
              $(".dialog button").each(->
                $(this).attr("disabled", false)
              )
            )
            return

      prevQuestionID = @getPrevQuestionID(question)
      @storage.saveQuestion @get("model"), question, prevQuestionID
      .then( (result) =>
        id = question.id
        if id == null
          for tempQuestion in result.get("questions.content")
            if tempQuestion.get("variableName") == question.get("variableName")
              question.set("id", tempQuestion.id)
              break;
        @set("questionSaveSuccess", true)
        @send "closeDialog"
        @send "loadingOff" 
        @setupDisplayedQuestions(@findPageByQuestion(question))
        @setupQuestionSearchArray()
        Ember.run.next(=>
          $(".dialog button").each(->
            $(this).attr("disabled", false)
          )
          @setupQuestionChangedAnimation(question)
        )
      , =>
        @send "loadingOff" 
        Ember.run.next( ->
          question.set("hasErrors", true)
          $(".dialog button").each(->
            $(this).attr("disabled", false)
          )
        )
      )










