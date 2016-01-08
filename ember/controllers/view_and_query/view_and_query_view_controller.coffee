LabCompass.ViewAndQueryViewController = LabCompass.GridController.extend LabCompass.WithProject,
	needs: ["project", 'form', 'application']
	breadCrumb: "View Data"

	noDownloadPermission: Ember.computed.not("model.canExport")

	isDomLoading: false

	codebookLink: (->
		id = @get('model.projectID')
		"/projects/#{id}/codebook"
	).property 'model.id'

	additionalCodeBookFields: ['key2', 'key2']


	showSelectAll: (->
		formArray = @get("formCheckBoxes")
		#should never have a length of 0 because then the 
		#empty state message will be shown
		if formArray.length == 1 
			return false
		else
			return true
	).property("formCheckBoxes")


	resizeDataExportPopup: ->
		document.getElementById('data-export-popup').style.overflowY = "auto"
		heightOfPopup = $("#data-export-popup").height()
		topValPopup = $("#data-export-popup").css("top")
		topValPopup = topValPopup.substring(0, topValPopup.length-2)
		totalHeight = heightOfPopup + Number(topValPopup)
		if totalHeight > $(window).height()
			$("#data-export-popup").css("bottom", "20px")
		else 
			$("#data-export-popup").css("bottom", "auto")

	filterColumnsByForm: (name, add=false) ->
		colIndexes = @get("model.formIndexes")[name]["column_indexes"]
		for index in colIndexes
			@get("data_table").api().column(index).visible(add)
		#@computeEachFilledPercent()
		@get("data_table").api().columns.adjust().draw()
		@setPaginationRow()


	showHideAllForms: (add)->
		api = @get("data_table").api()
		for index in api.columns().indexes()
			if index > 0
				api.column(index).visible(add)
		api.columns.adjust().draw()
		@setPaginationRow()
		if add
			Ember.run.later(=>
				Ember.run.next(=>
					#@computeEachFilledPercent()
				)
			, 500)

	handleDemoStuff: ->
		myModel = @get('project')
		tips = $(".joyride-tip-guide")
		if myModel.get("isDemo")
          if myModel.get("demoProgress.enterEditProgress") == true && myModel.get("demoProgress.viewDataSortSearch") == false
            $("#searchSortJoyride").foundation('joyride','off')
            $("#searchSortJoyride").foundation('joyride','start')
            $(".joyride-close-tip").remove()
            tips = $(".joyride-tip-guide")
            $($(".tabs").find("a")[0]).attr("id", "queryTabJoyride")
            $(".joyride-next-tip").on 'click', =>
              $(".joyride-next-tip").remove()
              $($(".tabs").find("a")[0]).addClass("animated pulse infinite")
              $($(".tabs").find("a")[0]).css("box-shadow", "0px 0px 0px 3px #82bbe6")         
              $($(".tabs").find("a")[0]).on 'click', =>
                $($(".tabs").find("a")[0]).removeClass("animated pulse infinite")
                $($(".tabs").find("a")[0]).css("box-shadow", "none")
                myModel.set("demoProgress.viewDataSortSearch", true)
                @storage.updateDemoProgress(myModel.get("id"), myModel.get("demoProgress"))     
	setExportParams: ->
		@set("model.exportParams.downloadOptions", @get("model.downloadOptions"))
		@set("model.exportParams.projectID", @get("model.projectID"))
		@set("model.exportParams.queryConjunction", "and")
		@set("model.exportParams.queryParams", [])
		@set("model.exportParams.queriedForms", @getExportFormsString())


	getExportFormsString: ->
		exportForms = {}
		for formObj in @get("model.formCheckBoxes")
			exportForms[formObj.formID] = formObj.get("checked")
		return exportForms

	actions:
		dataDownloaded: ->
			@send "closeDialog"
		
		codebookDownloaded: ->
			@send "closeDialog"
	
		export: ->
			exportQuery = @storage.createNewQuery(@get("project"))
			exportQuery.set("hasBlockedForms", @get("model.hasBlockedForms"))
			@send "openDialog", "confirm_download_project_grid", exportQuery, "confirmDownloadDialog"
			Ember.run.next =>
				$(document).on 'opened', =>
					document.getElementsByTagName("body")[0].style.overflow = "hidden"
					document.getElementById('data-export-popup').style.overflowY = "auto"
					heightOfPopup = $("#data-export-popup").height()
					topValPopup = $("#data-export-popup").css("top")
					topValPopup = topValPopup.substring(0, topValPopup.length-2)
					totalHeight = heightOfPopup + Number(topValPopup)
					if totalHeight > $(window).height()
						$("#data-export-popup").css("bottom", "20px")	

				$(window).on('resize', @resizeDataExportPopup)


				$(document).on 'closed', =>
					document.getElementsByTagName("body")[0].style.overflow = "auto"
					$(document).off 'opened'
					$(window).off('resize', @resizeDataExportPopup)

		codebook: ->
			codebookQuery = @storage.createNewQuery(@get("project")) # used for form checkboxes
			codebookQuery.set("hasBlockedForms", @get("model.hasBlockedForms"))
			
			@send "openDialog", "confirm_download_codebook", codebookQuery, "confirmDownloadCodebook"
			#checkBoxes = @get("model.exportCheckBoxes")
			#for formObj, index in @get("model.formCheckBoxes")
			#	checkedVal = formObj.get("checked")
			#	checkBoxes[index].set("checked", checkedVal)
