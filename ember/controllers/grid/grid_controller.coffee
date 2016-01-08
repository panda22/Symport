LabCompass.GridController = Ember.ObjectController.extend

	data_table: null

	isLoaded: false
	loadingText: "Table Loading..."
	gridSortAsc: true
	gridSortUnfilledFirst: true
	gridSortColumn: 0
	gridSortQuestionType: "text"
	sortTypes: Ember.A([
		"A-Z 0-9 unfilled first",
		"A-Z 0-9 unfilled last",
		"Z-A 9-0 unfilled first",
		"Z-A 9-0 unfilled last",
		"First Created On Top",
		"Last Created On Top",
		"First Edited On Top",
		"Last Edited On Top"
	])
	subjectSortTypes: Ember.A([
		"First Created On Top",
		"Last Created On Top",
		"First Edited On Top",
		"Last Edited On Top"
	])
	sortVariables: Ember.A([])
	isSubjectDateComp: false
	isCreatedAt: false
	subjectFilterText: ""
	curSortType: "First Created On Top"
	curSortVariable: "Subject ID"
	sortedData: []
	isLoading: false
	noLongerLoading: Ember.computed.not("isLoading")

	stillLoading: (->
		if @get("isLoading") == true
			@send "loadingOn"
		else
			@send "loadingOff"
	).observes "isLoading"

	loadGrid: (->
		@set("isLoading", true)
		@set("loadingText", "Table Loading...")
		if @get("model.noDataView")
			@set("isLoaded", true)
			@set("isLoading", false)
			return
		if @get("model.allCompleted") == true
			@set("sortedData", @get("model.grid"))
			Ember.run.next(=>
				@constructDataTableOnLoad()
				@set("isLoaded", true)
				@set("model.allCompleted", false)
			)
	).observes("model.allCompleted")

	finishLoading: (->
		@send "loadingOff"
	).observes("noLongerLoading")


	constructDataTableOnLoad: ->
		@set("curSortType", "First Created On Top")
		@set("curSortVariable", "Subject ID")
		if @get("model.hasNoData") or $("#main-data-table").html() != ""
			return
		@constructDataTable()
		Ember.run.next(=>
			@set("isLoading", false)
		)

	constructDataTable: (header=null, grid=null) ->
		thisController = @
		$(window).bind("resize", @tableResizeToWindow)
		windowPos = $(window).scrollTop()
		Ember.run.next ( =>
			table_columns = []
			if header == null
				for heading in @get("model.header")
					#if heading.display == true
					table_columns.push({
						"title": heading.value,
						})
			else
				table_columns = header
			data = if grid == null then @get("sortedData") else grid
			new_table = @get("data_table")
			new_order = [[0, 'asc']]
			try
				if new_table != null
					new_table.fnDestroy()
					new_order = []
				new_table = $("#main-data-table").dataTable({
					data: data,
					columns: table_columns,
					"columnDefs": [{ "type": "string"}],
					order: new_order,
					ordering: false,
					"autoWidth": false,
					"paging": true,
					"lengthMenu": [25, 50, 100],
					"fnDrawCallback": ->
						thisController.setDataTableStyleOnDraw($(this), this)
				})
			catch error
				console.error error
				console.error error.stack
				return
			
			@set("data_table", new_table)
			api = new_table.api()
			num_columns = api.columns()[0].length
			@set("table_dom_obj", $(".table-wrapper"))
			# TODO: uncomment to bring back filled percent
			# @computeEachFilledPercent()
			$(window).scrollTop(windowPos)
		)

	#######################################################################
	#
	# grid draw functions
	# happen automatically every time grid is drawn
	#
	#######################################################################

	handleConditionallyBlockedCells: ->
		@get("data_table").find("td").each(->
			if $(this).html() == "\u200d"
				$(this).addClass("conditionally-blocked")
		)

	setDataTableStyleOnDraw: (tableJQueryObj, tableJSObj) ->
		Ember.run.next(=>
			@send "loadingOn"
			Ember.run.later(=>
				$(".dataTables_length").closest(".row").hide()
				container = tableJQueryObj.closest(".table-wrapper")
				@tableResizeToWindow()
				@setPaginationRow()

				$(".static-first-cell-wrapper").remove()
				staticFirstCell = $("<div class='static-first-cell-wrapper table-header'></div>")
				$("#main-data-table_wrapper").append(staticFirstCell)
				@setStaticFirstCell(container, staticFirstCell)

				$(".static-column-wrapper").remove()
				staticColumnWrapper = $("<div class='static-column-wrapper content'></div>")
				$("#main-data-table_wrapper").append(staticColumnWrapper)
				@setStaticColumn(container, staticColumnWrapper)

				$("#main-data-table_wrapper .static-head-wrapper").remove()
				staticHeadWrapper = $("<div class='static-head-wrapper table-header'></div>")
				$("#main-data-table_wrapper").append(staticHeadWrapper)
				@setStaticHeader(container, staticHeadWrapper)

				if !Ember.isEmpty(@get("model.questionToForm"))
					@setColumnColorHover()
				@tableResizeToWindow()
				@setPaginationEvents(tableJSObj)
				@setHoverOverRow()
				# TODO uncomment to bring back gray conditional cells
				# @handleConditionallyBlockedCells()

				$("html, div").addClass("hide-scrollbar");
				window.setTimeout(->
					$("html, div").removeClass("hide-scrollbar");
				, 50)
				@send "loadingOff"
			, 50)
		)

	setPaginationRow: ->
		tableJQueryObj = $("#main-data-table")
		container = tableJQueryObj.closest(".table-wrapper")
		$(".pagination-row").remove()
		paginationRow = container.find(".dataTables_info").closest(".row")
		entries = paginationRow.find("#main-data-table_info")
		if entries.length == 0
			return
		subjectIDString = entries.html().replace(/entries/g, "Subject IDs")
		entries.html(subjectIDString).addClass("card-details")
		container
			.parent()
			.append(paginationRow
				.clone()
				.addClass("pagination-row")
				.removeClass("inner-pagination-row")
				.css("width", "95%"))
		paginationRow.addClass("inner-pagination-row")
		Ember.run.next(->
			$(".pagination-row li.paginate_button").each(->
				if $(this).text() == "…"
					$(this).addClass("unavailable")
			)
		)

	setStaticHeader: (container, headWrapperObj) ->
		headerObj = $("<div class='static-header'></div>")
		headWrapperObj.append(headerObj)
		headerColors = $("<div class='static-header-colors'></div>")
		headWrapperObj.append(headerColors)
		tableObj = container.find("#main-data-table")
		headerObj.width(tableObj.width() + 50)
		headerColors.width(tableObj.width() + 50)
		controller = @
		tableObj.find("th").each(->
			newTh = $("<div class='static-header-item'></div>")
			newTh.html("<span>" + $(this).html() + "</span>")
			newTh.css({
					"width": $(this).css("width"),
					"height": (parseInt($(this).css("height")) - 4) + "px"
				})
			headerObj.append(newTh)
			newColorTh = $("<div class='header-color-item color-none'></div>")
			newColorTh.css({
					"width": $(this).css("width")
				})
			if controller.get("model.questionToForm") and !Ember.isEmpty(controller.get("model.questionToForm"))
				questionName = controller.convertHeaderNameToQuestionName($(this).text())
				if questionName != null
					formIndex = controller.get("model.questionToForm")[questionName].index
					newColorTh.addClass(controller.getHeadingColorClass(formIndex))
			headerColors.append(newColorTh)
		)
		@setHeaderScroll(headWrapperObj, container)
		# TODO: why was this here??
		#if $(".static-header .static-header-item").length > 100
		#	Ember.run.later(=>
		#		@resizeHeader()
		#	, $(".static-header .static-header-item").length * 2)


	resizeHeader: ->
		$("#main-data-table th").each( (i) ->
			$(".static-header .static-header-item:eq(#{i})").width($(this).outerWidth())
			$(".static-header-colors .header-color-item:eq(#{i})").width($(this).outerWidth())
		)


	setColumnColorHover: ->
		controller = @
		$(".header-color-item").hover(->
			index = $(this).index()
			varName = $(this).parent().parent().find(".static-header div:eq(#{index})").text()
			questionName = controller.convertHeaderNameToQuestionName(varName)
			if questionName == null
				return
			formName = controller.get("model.questionToForm")[questionName].name
			toolTip = $("<div class='column-tool-tip'>" + formName + "</div>")
			$("body").append(toolTip)
			toolTip.css({
				top: $(this).offset().top - $(".top-bar").height() + 25,
				left: $(this).offset().left
			})
			
		, ->
			$(".column-tool-tip").remove()
		)

	convertHeaderNameToQuestionName: (name)->
		if name of @get("model.questionToForm")
			return name
		if name == "Subject ID" or name == "Total Filled %"
			return null
		splitName = name.split("_")
		splitName.pop()
		newName = splitName.join("_")
		if newName of @get("model.questionToForm")
			return newName
		if name.indexOf(" ") != -1
			splitName = name.split(" ")
			if splitName[splitName.length - 1] of @get("model.questionToForm")
				return splitName[splitName.length - 1]
		return null


	setStaticColumn: (container, colWrapper) ->
		tableObj = container.find("#main-data-table")
		firstHeader = tableObj.find("tr th:first-child")
		#colWrapper.height(container.height() - firstHeader.height() - 27)
		staticColumn = $("<div class='static-column'></div>")
		colWrapper.append(staticColumn)
		staticColumn.height(tableObj.height() - firstHeader.height() - 17)
		colWrapper.css("top", (parseInt(firstHeader.css("height")) + 1) + "px")
		tableObj.find("tr td:first-child").each(->
			newCell = $("<div class='static-column-item'></div>")
			newCell.html("<span>" + $(this).html() + "</span>")
			newCell.css({
				"width": $(this).css("width"),
				"height": $(this).css("height")
			})
			staticColumn.append(newCell)
		)
		@setColumnScroll(colWrapper, container)

	setStaticFirstCell: (container, firstCellWrapper) ->
		tableObj = container.find("#main-data-table")
		cellObj = $("<div class='static-first-cell'></div>")
		headerColors = $("<div class='static-header-colors'></div>")
		firstCellWrapper.append(cellObj)
		firstCellWrapper.append(headerColors)
		firstHeader = tableObj.find("tr th:first-child")
		cellObj.html("<span>" + firstHeader.text() + "</span>")
		cellObj.css({
			"width": firstHeader.css("width"),
			"height": (parseInt(firstHeader.css("height")) - 4) + "px"
		})
		headerColors.css("width", firstHeader.css("width"))


	setHeaderScroll: (headWrapperObj, tableWrapperObj) ->
		tableWrapperObj.scroll(->
			headWrapperObj.scrollLeft(tableWrapperObj.scrollLeft())
		)
		headWrapperObj.scroll(->
			tableWrapperObj.scrollLeft(headWrapperObj.scrollLeft())
		)
		Ember.run.next(->
			headWrapperObj.scrollLeft(tableWrapperObj.scrollLeft())
		)

	setColumnScroll: (colWrapperObj, tableWrapperObj) ->
		tableWrapperObj.scroll(->
			colWrapperObj.scrollTop(tableWrapperObj.scrollTop())
		)
		colWrapperObj.scroll(->
			tableWrapperObj.scrollTop(colWrapperObj.scrollTop())
		)
		Ember.run.next(->
			colWrapperObj.scrollTop(tableWrapperObj.scrollTop())
		)

	tableResizeToWindow: ->
		winWidthAdjusted = $(window).width() - $("#sidebar-id").width() - 80
		tableWidthAdjusted = $("#main-data-table").width() + 9
		newMaxWidth = Math.min(winWidthAdjusted, tableWidthAdjusted)
		container = $(".table-wrapper")
		container.width(newMaxWidth)
		newMaxHeight = Math.min($(window).height() - 100, $("#main-data-table").height() + 10)
		container.height(newMaxHeight)
		container.find(".static-head-wrapper").width(container.width() - 9)
		firstHeader = $("#main-data-table tr th:first-child")
		newColumnHeight = Math.min($("#main-data-table").height() - firstHeader.height() - 18, newMaxHeight - firstHeader.height() - 27)
		container.find(".static-column-wrapper").height(newColumnHeight - 4)

	setPaginationEvents: (dataTable) ->
		api = dataTable.api()
		$(".pagination-row a").removeAttr("href")
		$(".pagination-row li").removeClass("unavailable")
		$(".pagination-row a").click(->
			text = $(this).text()
			actualLink = $(".inner-pagination-row a:contains('#{text}')")
			actualLink.trigger("click")
		)

	setHoverOverRow: ->
		$("#main-data-table tr, .static-column .static-column-item").hover(->
			index = $(this).index()
			$("#main-data-table tbody tr:eq(#{index})").addClass("row-highlight")
			$(".static-column .static-column-item:eq(#{index})").addClass("row-highlight")
		, ->
			$(".row-highlight").removeClass("row-highlight")
		)

	computeEachFilledPercent: (setHTMLElements=true) ->
		# TODO: remove this to bring back filled percent
		return
		data = @get("sortedData")
		api = null
		visibleRows = []
		htmlToReset = []
		if @get("data_table") != null
			api = @get("data_table").api()
			for i in [0...api.columns()[0].length]
				visibleRows[i] = api.column(i).visible()
		for row, j in data
			numerator = 0
			denominator = 0
			for val, i in row
				if i < 2 or (api != null and visibleRows[i] == false)
					continue
				if val == "" or val == "No Response"
					denominator += 1
				else if val != "\u200d" and val != "\u200b"
					numerator += 1
					denominator += 1
			percent = 0
			if denominator != 0
				percent = (numerator/denominator) * 100
			row[1] = percent.toFixed(2)
			if setHTMLElements and j <= @get("pageLength")
				htmlToReset.push({row: j+1, amount: percent.toFixed(2)})
		if setHTMLElements
			Ember.run.next(->
				for info in htmlToReset
					$("#main-data-table").find("tr:eq(#{info.row}) td:eq(1)").text(info.amount)
			)


	getHeadingColorClass: (form_num) ->
		i = (form_num % 11)
		return ("color-" + i)

	#######################################################################
	#
	# grid actions
	#
	#######################################################################

	pageLengthOptions: Ember.A([
		25,
		50,
		100
	])

	pageLength: Ember.computed(->
		@pageLengthOptions[0]
	)

	setPageSize: (->
		@get("data_table").api().page.len(@get("pageLength")).draw()
	).observes("pageLength")

	

	updateCurSort: (->
		if @get("curSortVariable") == "Subject ID" and @get("sortTypes").length != 8
			types = Ember.A(@get("sortTypes"))
			@set("sortTypes", Ember.A([]))
			@set("sortTypes", types.concat(@get("subjectSortTypes")))
		else if @get("curSortVariable") != "Subject ID" and @get("sortTypes").length == 8
			for i in [1..4]
				@get("sortTypes").popObject()
			@set("curSortType", @get("sortTypes")[0])
		colNumber = -1
		asc = true
		unfilledFirst = true
		isSubjectDateComp = false
		isCreatedAt = false
		switch @get("curSortType")
			when @get("sortTypes")[0]
				asc = true
				unfilledFirst = true
			when @get("sortTypes")[1]
				asc = true
				unfilledFirst = false
			when @get("sortTypes")[2]
				asc = false
				unfilledFirst = true
			when @get("sortTypes")[3]
				asc = false
				unfilledFirst = false
			when @get("sortTypes")[4]
				asc = true
				isSubjectDateComp = true
				isCreatedAt = true
			when @get("sortTypes")[5]
				asc = false
				isCreatedAt = true
				isSubjectDateComp = true
			when @get("sortTypes")[6]
				asc = true
				isCreatedAt = false
				isSubjectDateComp = true
			when @get("sortTypes")[7]
				asc = false
				isCreatedAt = false
				isSubjectDateComp = true

		for varName, i in @get("model.header")
			if varName.value == @get("curSortVariable")
				colNumber = i
				@set("gridSortQuestionType", varName.type)
				break
		@sortRows(colNumber, asc, unfilledFirst, isSubjectDateComp, isCreatedAt)
	).observes("curSortVariable", "curSortType")

	isLessThan: (lhs, rhs, asc, unfilledFirst, isSubjectDateComp=false, isCreatedAt=false) ->
		if isSubjectDateComp
			dates = @get("model.subjectDates")
			if isCreatedAt
				if dates[lhs].created == dates[rhs].created
					return if lhs < rhs then -1 else 1
				if asc
					return if dates[lhs].created < dates[rhs].created then -1 else 1
				else
					return if dates[lhs].created > dates[rhs].created then -1 else 1
			else
				if dates[lhs].modified == dates[rhs].modified
					return if lhs < rhs then -1 else 1
				if asc
					return if dates[lhs].modified < dates[rhs].modified then -1 else 1
				else
					return if dates[lhs].modified > dates[rhs].modified then -1 else 1
		questionType = @get("gridSortQuestionType")
		comparator = @container.lookup("comparator:#{questionType}")
		op = if asc then ">" else "<"
		resp = comparator.compute(op, lhs, rhs)
		if (!(isNaN(lhs)) and !(isNaN(rhs)) and lhs != "" and rhs != "")
			lhs = Number(lhs)
			rhs = Number(rhs)
		if lhs == rhs
			return 0
		# TODO: figure out business logic for conditionally closed sorting
		if lhs == "" or lhs == "\u200E" # or lhs == "\u200D"
			return if (unfilledFirst == true) then -1 else 1
		if rhs == "" or rhs == "\u200E" # or rhs == "\u200D"
			return if (unfilledFirst == true) then 1 else -1
		if typeof resp != "undefined" and resp != null
			return if resp == true then 1 else -1
		if lhs < rhs
			return if (asc == true) then -1 else 1
		if rhs <= lhs
			return if (asc == true) then 1 else -1

	sortRows: (colNumber, asc=true, unfilledFirst=true, isSubjectDateComp, isCreatedAt) ->
		if @get("data_table") == null
			return
		@set("gridSortColumn", colNumber)
		@set("gridSortAsc", asc)
		@set("gridSortUnfilledFirst", unfilledFirst)
		@set("isSubjectDateComp", isSubjectDateComp)
		@set("isCreatedAt", isCreatedAt)
		@set("sortedData", @sortByColumn(@get("sortedData")))
		tableApi = @get("data_table").api()
		tableApi.row().remove();
		for row in @get("sortedData")
			tableApi.row.add(row)
		tableApi.draw()
		newWidth = parseInt($(".dataTables_scrollHeadInner th:eq(0)").css("width"))
		$(".DTFC_LeftWrapper").width(newWidth + "px")

	sortByColumn: (array) ->
		colNumber = @get("gridSortColumn")
		asc = @get("gridSortAsc")
		unfilled = @get("gridSortUnfilledFirst")
		isSubjectDateComp = @get("isSubjectDateComp")
		isCreatedAt = @get("isCreatedAt")
		array.sort( (a, b) =>
		  retVal = @isLessThan(a[colNumber], b[colNumber], asc, unfilled, isSubjectDateComp, isCreatedAt)
		  return retVal
		)
		array

	filterRowTypes: Ember.A([
		"Subject IDs",
		"All Data"
	])

	filterRowType: Ember.computed(->
		@filterRowTypes[0]
	)

	filterRowsBySubjectId: (->
		id = @subjectFilterText
		table = @get("data_table").api()
		if @get("filterRowType") == "Subject IDs"
			table.rows().each(->
				this.search("")
			)
			table.column(0).search(id).draw()
		else
			table.column(0).search("")
			table.rows().each(->
				this.search(id).draw()
			)
	).observes("subjectFilterText", "filterRowType")

	resetController: ->
		if @get("data_table")
			@get("data_table").fnDestroy()
		@set("data_table", null)
		$(".table-wrapper").html("<table id='main-data-table'></table>")
		#@set("activePage.grid", false)
		@set("isLoaded", false)	
		@set("gridSortAsc", true)
		@set("gridSortUnfilledFirst", true)
		@set("gridSortColumn", 0)
		@set("subjectFilterText", "")
		@set("curSortType", "")
		@set("curSortVariable", "")
		#@set("sortVariables", Ember.A([]))
		#@set("viewableData", [])
		#@set("filteredForms", {})
		#@set("gridRows", [])
		#@set("gridHeadings", [])
		@set("showQueryDetails", false)
		$(window).unbind("resize", @tableResizeToWindow)
		@set("loadingText", "")

	actions:
		filterByIDs: (id)->
			@filterRowsBySubjectId(id)
		
		enableForm: (add, id) ->
			for form in @get("model.formCheckBoxes")
				if form.name == id
					form.set("checked", add)
					break
			@filterColumnsByForm(id, add)
			if add == false
				$("#selectAllForms").prop("checked", false)
			else
				allFormsSelected = true
				$(".singleFormSelect").each(->
					if $(this).prop("checked") == false
						allFormsSelected = false
				)
				if allFormsSelected == true
					$("#selectAllForms").prop("checked", true)

		selectAllForms: (add) ->
			for form in @get("model.formCheckBoxes")
				if form.get("checked") != add
					form.set("checked", add)
			@showHideAllForms(add)
			$(".singleFormSelect").each(->
				if $(this).prop("checked") != add
					$(this).prop("checked", add)
			)

		testAction: (param, val) ->
			@set(param, val)
