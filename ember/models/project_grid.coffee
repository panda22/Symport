LabCompass.ProjectGrid = LD.Model.extend
	formQuestions: Ember.A([])
	allResponses: {}
	allCompleted: false

	session: null
	projectID: null

	NoDataErrorMessages: {
		form: "To view or query the data, you’ll first need to build at least one form. Go to create new form to begin this process."
		formPermission: "To view or query the data, you need to get permission to view project forms. Check with a project administrator to request access."
		question: "You don't have any data yet, go to Enter/Edit Data to start adding some Subject IDs!"
		questionPermission: "All of data in this project has been flagged as identifying information. Check with a project administrator to request access."
		response: "This project doesn't have any data to view or query, to collect some go to Enter and Edit Data."
	}

	query: null

	noDataError: null
	hasNoData: false
	noDataView: null

	hasBlockedPhi: false

	grid: []
	header: []
	formIndexes: {}
	subjectDates: {}
	queryInfo: Ember.A([])
	
	formCheckBoxes: Ember.A([])
	exportCheckBoxes: Ember.A([])

	activePage: Ember.Object.create({
		query: false
		grid: false
	})

	hasBlockedForms: false

	exportParams: {}
	
	downloadOptions: {
		includePhi: false
		useCodes: false
		emptyAnswerCode: ""
		conditionallyBlockedCode: ""
	}
	
	exportParamKeys: Ember.A([
		"projectID",
		"queryParams",
		"queriedForms",
		"queryConjunction",
		"downloadOptions"
	])

	loadQueryResults: (storage)->
		@resetModel()
		storage.projectQueryData(@get("query")).then (result) =>
			@setProperties(result)
			queryInfo = result.queryInfo
			for param in queryInfo.params
				param.n = param.total_subjects - param.removed_subjects.length
			@set("allCompleted", true)

	loadData: (projectID, storage)->
		@resetModel()
		storage.projectViewData(projectID).then (result) =>
			if result.noDataError != null
				@set("noDataError", result.noDataError)
				@constructNoDataError()
			else
				@set("grid", result.grid)
				@set("header", result.header)
				@set("formIndexes", result.formIndexes)
				@set("subjectDates", result.subjectDates)
				@set("canExport", result.canExport)
				@set("hasBlockedForms", result.formBlocked)
				@set("questionToForm", result.questionToForm)
				for formName, index of @get("formIndexes")
					@get("formCheckBoxes").pushObject(Ember.Object.create({
						name: formName
						nameId: formName.split(" ").join("-").replace(/\W/g, '')
						checked: true
						formID: index.id
						hasNoQuestions: if index.column_indexes.length == 0 then true else false
						shortName: if formName.length > 27 then formName.substring(0,27) + "..." else formName
						projectShortName: if formName.length > 42 then formName.substring(0,42) + "..." else formName 
						formShortName: if formName.length > 39 then formName.substring(0,39) + "..." else formName
					}))
					@get("exportCheckBoxes").pushObject(Ember.Object.create({
						name: formName
						exportId: (formName.split(" ").join("-").replace(/\W/g, '') + "-export")
						checked: true
						#hasNoQuestions: if index.column_indexes.length == 0 then true else false
						#formID: index.id
						shortName: if formName.length > 27 then formName.substring(0,27) + "..." else formName
						projectShortName: if formName.length > 42 then formName.substring(0,42) + "..." else formName 
						formShortName: if formName.length > 39 then formName.substring(0,39) + "..." else formName
					}))
			@set("allCompleted", true)

	constructNoDataError: ->
		@set("noDataView", @NoDataErrorMessages[@get("noDataError")])


	resetModel: ->
		@set("subjectDates", {})
		@set("grid", [])
		@set("header", [])
		@set("formIndexes", {})
		@set("formCheckBoxes", Ember.A([]))
		@set("grid", [])
		@set("header", [])
		@set("formIndexes", {})
		@set("queryParams", {})
		@set("formQuestions", Ember.A([]))
		@set("allResponses", {})
		@set("allCompleted", false)
		@set("hasBlockedPhi", false)
		@set("noDataError", null)
		@set("hasNoData", false)
		@set("noDataView", null)
