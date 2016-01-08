#******************************************************

# usage notes:

# purpose:
# 	intended to be an element that can be dynamically added to the query builder.
# 	this corresponds to one query parameter

# params:
# 	parentController: controller that for this. needed for storage access
# 	forms: array of forms for the project
# 	param: query parameter object that this edits. see the model in query_param.coffee
# 		for more details
# 	action: handler for deleting this
# 	isTypeSet: if set to true this will start with param info already loaded
# 		intended for loading a param rather than creating a new one
# 		also changes answer from html input to answer component

# other notes:
# 	uses drop-down element for form, questions, and operator
# 	uses answer component for answer

#******************************************************

LabCompass.QueryBuilderComponent = Ember.Component.extend
	isLoading: true
	curForm: null
	curQuestion: null
	isManyToOneField: false
	isManyToOneCount: false
	isManyToOneOptions: []
	answer: Ember.computed(->
		@get("parentController").storage.createModel("formAnswer")
	)

	ids: ( ->
		Ember.Object.create({
			form: "form-" + @get("param.sequenceNum")
			question: "question-" + @get("param.sequenceNum")
			operator: "operator-" + @get("param.sequenceNum")
			value: "value-" + @get("param.sequenceNum")
		})
	).property "param.sequenceNum"

	hasError: false
	setHasError: (->
		if (
			@get("param.errors.formName") or
			@get("param.errors.questionName") or
			@get("param.errors.operator") or
			@get("param.errors.value")
		)
			@set("hasError", true)
		else
			@set("hasError", false)
	).observes("param.errors.formName", "param.errors.questionName", "param.errors.operator", "param.errors.value")

	setQuestionType: (->
		if @param.get("questionType") == ""
			@set("isTypeSet", false)
		else
			@set("isTypeSet", true)
	).observes("param.questionType")

	setQuestionChoices: ((reset=false)->
		if @get("param.formName") != ""
			@$().find(".query-question-selector input:eq(0)").parent().parent().addClass("placeholder")
		else
			@$().find(".query-question-selector input:eq(0)").parent().parent().removeClass("placeholder")
		if reset != true
			@set("param.questionName", "")
			@set("questionChoices", Ember.A([]))
		if @get("isLoading") == false
			@set("param.questionType", "")
		formFound = false
		for form in @get("forms")
			if form.name == @get("param.formName")
				@set("curForm", form)
				@set("questionChoices", form.questions)
				@$().find("select:eq(0) option:eq(0)").hide()
				formFound = true
				break
		if formFound == false
			@set("curForm", null)
	).observes("param.formName")

	setOperandChoices: ((reset=false)->
		if @get("param.questionName") != ""
			@$().find(".query-operator-selector input:eq(0)").parent().parent().addClass("placeholder")
		else
			@$().find(".query-operator-selector input:eq(0)").parent().parent().removeClass("placeholder")
		if reset != true
			@set("param.operator", "")
			@set("operandChoices", Ember.A([]))
		questionType = ""
		questionFound = false
		for question in @get("questionChoices")
			if question.variableName == @get("param.questionName")
				questionType = question.type
				#@set("curQuesType", questionType)
				questionFound = true
				@set("param.questionType", question.type)
				break
		if questionFound == true
			operators = @getOperatorArray(questionType)
			@set("operandChoices", operators)
			#@set("param.operator", @get("operandChoices")[0].display)
	).observes("param.questionName")

	getOperatorArray: (questionType) ->
		temp = Ember.A([])
		for obj in @container.lookup("comparator:#{questionType}").supportedOperators
			temp.pushObject(obj)
		if questionType == "text"
			for obj in @container.lookup("comparator:checkbox").supportedOperators
				temp.pushObject(obj)
		temp

	formNames: Ember.A([])
	setFormNames: (->
		@set("formNames", @get("forms").mapBy("name"))
	).observes("forms").on("init")
	questionChoices: Ember.A([])
	questionVarNames: Ember.A([])
	setQuestionVarNames: (->
		@set("questionVarNames", @get("questionChoices").mapBy("variableName"))
	).observes("questionChoices")
	operandChoices: Ember.A([])
	operandDisplays: Ember.A([])
	setOperandDisplays: (->
		@set("operandDisplays", @get("operandChoices").mapBy("display"))
	).observes("operandChoices")

	didInsertElement: ->
		unless Ember.isEmpty(@get("param.formName"))
			formName = @get("param.formName")
			quesType = @get("param.questionType")
			quesName = @get("param.questionName")
			opName = @get("param.operator")
			answer = @get("param.value")
			if formName != ""
				@setQuestionChoices(true)
				@setOperandChoices(true)
				window.setTimeout(=>
					if @$()
						@$().find(".query-question-selector input").val(quesName)
						@$().find(".query-operator-selector input").val(opName)
						@set("param.operator", opName)
						#@$().find("input:eq(3)").val(answer)
						@checkValidQuestionName()
						Ember.run.next(=>
							@set("answer.answer", answer)
							@set("questionType", quesType)
							@set("isTypeSet", if quesName == "" then false else true)
							@$().find(".query-form-selector input").val(formName)
						)
				, 600)

	checkCorrectInput: (domObj, arr, paramName)->
		found = false
		for val in arr
			if val == domObj.val()
				found = true
				break
		if !found
			domObj.val("")
		@get("param").set(paramName, domObj.val())

	checkValidQuestionName: (->
		name = @get("param.questionName")
		@get("answer").set("answer", "")
		tempQuestion = null
		for question in @get("questionChoices")
			if question.variableName == name
				tempQuestion = question
				break
		@createQuestionObj (tempQuestion)
	).observes("param.questionName")

	createQuestionObj: (question) ->
		@set("curQuestion", question)
		if question == null
			@param.set("questionType", "")
		else
			formID = @get("curForm").id
			questionID = @get("curQuestion").id
			if questionID and questionID.length
				@get("parentController").storage.getQuestion(formID, questionID, true).then (result) =>
					newQuestion = result
					#newQuestion.set("type", @convertQuestionType(question.type))
					@get("answer").set("question", newQuestion)
					@set("param.questionType", question.type)
					@get("answer").set("answer", @get("param.value"))
					@set("isManyToOneCount", false)
					@set("isManyToOneField", false)
					@set("param.isManyToOneCount", false)
				@set("param.isManyToOneInstance", false)
			else if question.variableName.indexOf("number of") != -1
				@set("isManyToOneCount", true)
				@set("isManyToOneField", true)
				@set("param.isManyToOneCount", true)
				@set("param.isManyToOneInstance", false)
			else
				@set("isManyToOneOptions", @get("parentController.uniqSecondaryIds")[formID])
				@set("isManyToOneCount", false)
				@set("isManyToOneField", true)
				@set("param.isManyToOneCount", false)
				@set("param.isManyToOneInstance", true)


	listenForAnswer: (->
		@set("param.value", @get("answer.answer"))
	).observes("answer.answer")

	actions:
		deleteQuery: (id) ->
			@sendAction("action", id)

		setAnswer: ->
			@set("param.value", @get("answer.answer"))

		preventKeyPress: ->
			return
