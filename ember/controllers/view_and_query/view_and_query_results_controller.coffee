LabCompass.ViewAndQueryResultsController = LabCompass.GridController.extend LabCompass.WithProject,
	needs: ["project", 'form', 'application']

	breadCrumb: (->
		myModel = @get('model')
		myQuery = myModel.get('query')
		if myQuery.get('id')
			#need to put name in here
			"Query Results"
		else
			"Query Results"
	).property("id")

	details_link: (->
		id = @get('project.id')
		"projects/#{id}/query_details"
	).property 'project'
	additionalDetailsField: ["queryInfo", "time", "date", "query_id"]

	setFormInstanceDetails: (->
		#@set("formInstanceDetails", Ember.A([]))
		allowedInstanceCounts = @get("model.queryInfo.allowedInstanceCounts")
		allInstanceCounts = @get("model.queryInfo.allInstanceCounts")
		for secondaryId, formInfo of @get("model.queryInfo.allAllowedInstances")
			matching = allowedInstanceCounts[secondaryId]
			total = allInstanceCounts[secondaryId]
			percentString = "0.00%"
			if total != 0
				percent = (matching / total) * 100
				percentString = percent.toFixed(2) + "%"
			formObj = Ember.Object.create({
				secondaryId: secondaryId,
				matching: matching,
				total: total,
				percent: percentString
			})
			@get("model.queryInfo.instanceInfo").pushObject(formObj)
	).observes("model.queryInfo.params")

	noDownloadPermission: Ember.computed.not("model.canExport")
	time: ""
	date: ""
	query_id: ""
	setTimeAndDate: (->
		@set("query_id", @get("model.query.id"))
		datetime = new Date()
		date = datetime.toDateString()
		@set 'date', date.slice(date.indexOf(" ")+1)
		time  = datetime.toLocaleTimeString()
		i = time.indexOf(" ")
		@set 'time', (time.slice(0, i-3) + time.slice(i))
	).observes "model.queryInfo"

	setExportParams: ->
		@set("model.exportParams.downloadOptions", @get("model.downloadOptions"))
		queryInfo = @get("session.queryParamInfo")
		@set("model.exportParams.projectID", queryInfo.get("projectID"))
		@set("model.exportParams.queryConjunction", queryInfo.get("queryConjunction"))
		params = []
		for param in queryInfo.get("queryParams")
			data = param._data
			params.push(data)
		@set("model.exportParams.queryParams", params)
		@set("model.exportParams.queriedForms", queryInfo.get("queriedForms"))
	

	queryDetailsString: {
		class: "show-details"
		string: "Show Details"
	}

	showQueryDetails: false

	canViewPhi: Ember.computed(->
		@storage.canViewProjectPhi(@get("project.id"))
	)

	toggleQueryDetailsString: (->
		obj = {}
		if @get("showQueryDetails") == false
			obj = {
				class: "show-details"
				string: "Show Details"
			}
		else obj = {
			class: "hide-details"
			string: "Hide Details"
		}
		@set("queryDetailsString", obj)
	).observes("showQueryDetails")

	resizeDataExportPopup: ->
		document.getElementById('data-export-popup').style.overflowY = "auto"

	checkForNext: ->
		downloadDataPopup = $(".dialog.large.data-export")
		if downloadDataPopup.length > 0
			myModel = @get('project')
			nextButtons = $(".joyride-next-tip")
			$(nextButtons[0]).trigger('click')
			$(nextButtons[1]).css("visibility", "hidden")
			$("#downloadDataPopupTools").addClass("animated pulse infinite")
			$("#data-export-popup").on 'closed', =>
				$("#downloadDataPopupTools").removeClass("animated pulse infinite")
				crumb = $(".breadcrumbs").find("li")
				$(crumb[1]).attr("id", "breadCrumbJoyride")
				$(nextButtons[1]).trigger('click')
				$(crumb[1]).addClass("animated pulse infinite")
				myModel.set("demoProgress.queryResultsBreadcrumbs", true)
				@storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
				$(nextButtons[2]).css("visibility", "hidden")
				$(crumb[1]).on 'click', =>
					$(crumb[1]).removeClass("animated pulse infinite")
		else
			window.setTimeout(=>
				@checkForNext()
			, 600)

	handleDemoProgress: ->
		myModel = @get('project')
		if myModel.get("isDemo") == true
			if myModel.get("demoProgress.queryBuilderProgress") == true
				if myModel.get("demoProgress.queryResultsDownload") == false
					$("#queryResultsJoyride").foundation('joyride','off')
					$("#queryResultsJoyride").foundation('joyride','start')
					$(".joyride-close-tip").remove()
					$("#downloadDataButton").addClass("animated pulse infinite")
					nextButtons = $(".joyride-next-tip")
					$(nextButtons[0]).css("visibility", "hidden")
					$("#downloadDataButton").on 'click', =>
						$("#downloadDataButton").removeClass("animated pulse infinite")
						$("#downloadDataButton").css("box-shadow", "none")
						myModel.set("demoProgress.queryResultsDownload", true)
						@storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
						@checkForNext()
				else if myModel.get("demoProgress.queryResultsBreadcrumbs") == false
					crumb = $(".breadcrumbs").find("li")
					$(crumb[1]).attr("id", "breadCrumbJoyride")
					nextButtons = $(".joyride-next-tip")
					$(nextButtons[0]).trigger('click')
					$(nextButtons[1]).trigger('click')
					$(crumb[1]).addClass("animated pulse infinite")
					myModel.set("demoProgress.queryResultsBreadcrumbs", true)
					@storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))
					$(nextButtons[2]).css("visibility", "hidden")
					$(crumb[1]).on 'click', =>
						$(crumb[1]).removeClass("animated pulse infinite")

	handleTransition: (transition) ->
		if @get("model.query") and @get("model.query.isSaved") == false and @get("model.query.id")
			if transition.targetName == "account.revalidate-session"
				return true
			if (transition.targetName == "view-and-query.query" and Ember.isEmpty(transition.queryParams.query) == false)
				transition.isAborted = false
				@set("model.activePage.grid", false)
				@set("isSavedQuery", false)
				@resetController()
			else if transition.targetName == "view-and-query.query"
				transition.isAborted = false
				transition.queryParams = {query: @get("model.query")}
				return true
			else
				@set("model.query.otherModel", @get("model.query"))
				queryController = @container.lookup("controller:view-and-query.query")
				queryController.set("storedTransition", transition)
				transition.abort()
				@send "openDialog", "confirm_unsaved_query", @get("model.query"), "viewAndQueryConfirmLeaveSavedQuery"
		else
			transition.isAborted = false
			@set("model.activePage.grid", false)
			@set("isSavedQuery", false)
			@resetController()
			return true

	isUnsavedQuery: false
	hasBeenUnsavedQuery: null
	isSavedQuery: false

	setUnsavedQuery: (->
		if @get("model.query") and @get("model.query.isSaved") == false
			@set("isUnsavedQuery", true)
		else
			@set("isUnsavedQuery", false)
	).observes("model", "model.query", "model.query.isSaved")

	setHasBeenUnsavedQuery: (->
		if @get("isUnsavedQuery")
			@set("hasBeenUnsavedQuery", true)
	).observes("isUnsavedQuery", "model")

	setIsSavedQuery: (->
		if @get("isUnsavedQuery") == false and @get("hasBeenUnsavedQuery")
			@set("isSavedQuery", true)
			@set("hasBeenUnsavedQuery", null)
		else
			@set("isSavedQuery", false)
	).observes("isUnsavedQuery")

	actions:
		goBackToQuery: ->
			history = @get("session.history")
			lastVisited = ""
			if history.length > 1
				lastVisited = history[history.length - 2]
			if lastVisited.indexOf("saved-queries") != -1
				@transitionToRoute(lastVisited)
			else
				@transitionToRoute "view-and-query.query", {queryParams: {query: @get("model.query")}}

		toggleQueryDetails: ->
			@set("showQueryDetails", !@get("showQueryDetails"))

		saveQuery: ->
			@send "openDialog", "save_query", @get("model.query"), "viewAndQueryConfirmSaveQuery"

		export: ->
			#@setExportParams()
			@send "openDialog", "confirm_download_query_results", @get("model.query"), "confirmDownloadDialog"
			Ember.run.next =>
				$(document).on 'opened', =>
					document.getElementsByTagName("body")[0].style.overflow = "hidden"
					document.getElementById('data-export-popup').style.overflowY = "auto"

				$(window).on('resize', @resizeDataExportPopup)

				$(document).on 'closed', =>
					document.getElementsByTagName("body")[0].style.overflow = "auto"
					$(document).off 'opened'
					$(window).off('resize', @resizeDataExportPopup)