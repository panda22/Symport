LabCompass.FormPreviewController = Ember.ObjectController.extend LabCompass.ResponseLogicMixin,

	breadCrumb: "Build Form - Preview Form"
	formResponse: (->
		@storage.createModel "formResponse",
			subjectID: '123'
			answers: @get "fakeAnswers"
			formStructure: @get "model"
	).property "model", "fakeAnswers"

	fakeAnswers: Ember.A([])

	getFakeAnswers: ->
		@get("model.sortedQuestions").map (question) =>
			ans = @storage.createModel "formAnswer", question: question
			ans.set('answer', null)
			ans


	QUESTIONS_PER_PAGE: 25

	isPaging: false

	setIsPaging: (->
		if @get("fakeAnswers.length") > @QUESTIONS_PER_PAGE
			@set("isPaging", true)
		else
			@set("isPaging", false)
	).observes("fakeAnswers.length")

	displayedAnswers: Ember.A([])

	paginatedAnswers: Ember.ArrayProxy.create({content: Ember.A([])})

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


	setupDisplayedQuestions: (curPage=null) ->
		if curPage == null
			curPage = @get("model.curPage")
		if @get("fakeAnswers.length") == 0
			@set("displayedAnswers", Ember.A([]))
			return
		@set("curSearchString", "")
		@set("model.curPage", curPage)
		start = curPage * @QUESTIONS_PER_PAGE
		@set("paginatedAnswers", Ember.A([]))
		@get("paginatedAnswers").pushObjects(@get("fakeAnswers").slice(start, start + @QUESTIONS_PER_PAGE))
		@set("displayedAnswers", @get("paginatedAnswers"))
		@set 'answerErrors', []
		@set "isErrors", false
		@setupPaginationInfo()

	setupPaginationInfo: ->
		allAnswers = @get("fakeAnswers")
		numQuestions = allAnswers.length
		lastQuestion = allAnswers[numQuestions - 1].get("question.sequenceNumber")
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
			pageObj.set("firstQuestionName", allAnswers[questionIndex].get("question.sequenceNumber"))
			lastIndex = Math.min(numQuestions - 1, questionIndex + @QUESTIONS_PER_PAGE - 1)
			pageObj.set("lastQuestionName", allAnswers[lastIndex].get("question.sequenceNumber"))
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
			lastQuestionName: lastQuestion,
			pages: pages,
			firstPage: firstPage,
			lastPage: lastPage
		}
		@set("paginationInfo", returnObj)


	listenForChangeInDisplayedQuestions: (->
		if @get("fakeAnswers") == null or @get("fakeAnswers.length") == 0
			@set("displayedAnswers", Ember.A([]))
			return
		@setupDisplayedQuestions()
	).observes("fakeAnswers")

	findPageByQuestion: (question) ->
		seqNum = question.get("sequenceNumber")
		return Math.floor((seqNum - 1) / @QUESTIONS_PER_PAGE)

	questionSearchArray: Ember.A([])

	setupQuestionSearchArray: (->
		if @get("fakeAnswers") == null or @get("fakeAnswers.length") == 0
			@set("questionSearchArray", Ember.A([]))
			return
		arr = Ember.A([])
		for answer in @get("fakeAnswers")
			question = answer.get("question")
			displayName = question.get("displayName")
			varName = question.get("variableName")
			if varName == ""
        arr.push("\u200b#{displayName}\u200b")
      else
        arr.push("#{displayName} \u200a[#{varName}]\u200a")
		@set("questionSearchArray", arr)
	).observes("fakeAnswers")

	curSearchString: ""

	searchForQuestion: (->
		if @get("curSearchString") == null or @get("curSearchString") == ""
      return
		varName = ""
		isVarNameSearch = true
		if (@get("curSearchString").indexOf("\u200a") != -1)
			varName = @get("curSearchString").split("\u200a")[1].slice(1, -1)
		else if (@get("curSearchString").indexOf("\u200b") != -1) # search for display name (header type)
      isVarNameSearch = false
      varName = @get("curSearchString").split("\u200b")[1]
		if varName != ""
			target = null
			for answer in @get("fakeAnswers")
				question = answer.get("question")
				if isVarNameSearch and question.get("variableName") == varName
          target = question
          break
        if !isVarNameSearch and question.get("displayName") == varName
          target = question
          break
			if target != null
				newPage = @findPageByQuestion(target)
				if newPage != @get("curPage")
					@setupDisplayedQuestions(newPage)
					Ember.run.next(=>
						Ember.run.later(=>
							@setupQuestionSearch(target)
						, 500)
					)
				else
					@set("curSearchString", "")
					@setupQuestionSearch(target)
	).observes("curSearchString")

	setupQuestionSearch: (question) ->
		Ember.run.next(->
			answerBoxDiv = $("#" + question.get('id')).find(".form-answer-box")
			if answerBoxDiv.length == 0
				answerBoxDiv = $("#" + question.get('id')).find(".header")
			answerBoxDiv.addClass("with-gray-shadow")
			curPos =  $('body').scrollTop()
			newPos = answerBoxDiv.offset().top
			bottomMargin = parseInt($(window).height()) - answerBoxDiv.height()
			target = answerBoxDiv.offset().top - (parseInt($(window).height()) / 2)
			shouldMove = ((curPos + bottomMargin - newPos) < 0 or (newPos - curPos) < 0)
			if shouldMove
				$('html, body').scrollTop(target)
				window.setTimeout(->
					answerBoxDiv.removeClass("with-gray-shadow")
				, 1000)
		)

	answerErrors: []
	showSaving: false
	showSuccess: false
	isErrors: false

	setAnswerErrors: ->
	    @set('showSaving', false)
	    $('.error-notification').removeClass("hide")
	    @set("isErrors", true)
	    retErrors = []
	    answers = @get("formResponse.sortedAnswers")
	    i = 1
	    for answer in answers
	      error = answer.get("errors.content.answer")
	      if error.length > 0
	        retErrors.push({
	          questionNumber:i,
	          displayNumber: answer.get('question.sequenceNumber')
	          appendString: ", "
	          })
	      i++
	    if retErrors.length > 0
	        retErrors[retErrors.length - 1]["appendString"] = ""
	    @set("answerErrors", retErrors)
	    if $(".error-notification").outerHeight() > 50 && $(".error-notification").hasClass("show")
	      $(".saveSlider")[0].style.height = $(".error-notification").outerHeight() + 7 + "px"

	showSuccessFlash: ->
	    @set('showSaving', false)
	    Ember.run.next ->
		    $('#success-flash').removeClass("hide")
		    if $("#success-flash").outerHeight() > 50 && !$("#success-flash").hasClass("success hide")
		        $(".saveSlider")[0].style.height = $("#success-flash").outerHeight() + 7 +  "px"

	actions:
		changePage: (pageInfo) ->
			@setupDisplayedQuestions(pageInfo.get("index"))
			Ember.run.next(->
				$("body").scrollTop(0)
			)

		saveFakeResponse: ->
		    $(".viewingText").css("visibility", "hidden")
		    @set('showSaving', true)
		    $(".saveSlider")[0].style.height = 50 + "px"
		    $('#success-flash').addClass("hide")
		    $('.error-notification').addClass("hide")

		    @storage.getErrorsForFormResponse(@get 'formResponse').then ((updatedResponse) =>
		      newSubject = (@get 'model.newSubject')
		      @set("isErrors", false)

		      @showSuccessFlash()

		    ), =>
		      @setAnswerErrors()

	    goToError:  (errorNum, error)->
	      errorPage = Math.floor((errorNum - 1) / @QUESTIONS_PER_PAGE)
	      if @get("curPage") != errorPage
	        @setupDisplayedQuestions(errorPage)
	      Ember.run.next( =>
	        targetDiv = $("#" + errorNum)
	        $('html, body').animate({
	          scrollTop: targetDiv.offset().top - ($(window).height() / 2)
	        }, 300)
	        @setAnswerErrors()
	      )



