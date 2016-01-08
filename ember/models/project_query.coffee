LabCompass.ProjectQuery = LD.Model.extend
	projectID: null
	forms: null
	secondaryIds: null
	queryParams: Ember.A([])
	noDataError: false

	uniqueSecondaryIds: {}

	setUniqueSecondaryIds: (->
		for formID, ids of @get("secondaryIds")
			temp = Ember.A([])
			for id in ids
				unless temp.contains(id)
					temp.pushObject(id)
			@get("uniqueSecondaryIds")[formID] = temp
	).observes "secondaryIds"

	validateAndSetQueryParams: (queryParams) ->
		paramIndexesToRemove = @getInvalidIndexes(queryParams).reverse()
		for index in paramIndexesToRemove
			queryParams.removeAt(index)

	getInvalidIndexes: (queryParams) ->
		@set("queryParams", queryParams)
		paramIndexesToRemove = []
		for param, i in queryParams
			formFound = false
			for form in @get("forms")
				if form.name == param.get("formName")
					formFound = true
					questionFound = false
					for question in form.questions
						if question.variableName == param.get("questionName")
							questionFound = true
							break
					if questionFound == false
						paramIndexesToRemove.push(i)
					break
			if formFound == false
				paramIndexesToRemove.push(i)
		paramIndexesToRemove
		