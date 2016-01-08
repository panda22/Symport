LabCompass.FormDataSlickHandler = Ember.Object.extend
  parentController: null

  rightGrid: null
  leftGrid: null
  headerMenu: null
  leftHeaderMenu: null

  gridOptions:
    enableCellNavigation: true
    enableColumnReorder: false
    syncColumnCellResize: true
    enableAddRow: false
    defaultColumnWidth: 170
    explicitInitialization: true
    headerRowHeight: 40
    rowHeight: 30

  setSlickGrid: ->
    tempLeftGrid = new Slick.Grid("#left-grid", [], [], @get("gridOptions"))
    tempRightGrid = new Slick.Grid("#right-grid", [], [], @get("gridOptions"))
    tempHeaderMenu = new Slick.Plugins.HeaderMenu({})
    leftHeaderMenu = new Slick.Plugins.HeaderMenu({})
    @set("headerMenu", tempHeaderMenu)
    @set("leftHeaderMenu", leftHeaderMenu)
    @set("leftGrid", tempLeftGrid)
    @get("leftGrid").registerPlugin(leftHeaderMenu)
    @set("rightGrid", tempRightGrid)
    @get("rightGrid").registerPlugin(tempHeaderMenu)

    @setBoundEvents(@get("leftGrid"), @get("rightGrid"))
    @set("parentController.actionHandler.leftGrid", @get("leftGrid"))
    @set("parentController.actionHandler.rightGrid", @get("rightGrid"))
    #@resizeWidth()
    #@resizeHeight()

  renderInitial: ->
    @get("leftGrid").init()
    @get("rightGrid").init()
    @reRenderGrids()
    @resizeHeight()
    @resizeWidth()

  reRenderGrids: (resetColumns=true) ->
    left = @get("leftGrid")
    right = @get("rightGrid")
    curData = @get("parentController.activeModel")

    if resetColumns
      left.setColumns(curData.get("leftColumns"))
    left.setData(curData.get("leftData"))
    #left.invalidateAllRows()
    @setGridStyle(left)
    left.render()
    if resetColumns
      right.setColumns(curData.get("rightColumns"))
      @resizeWidth()
    right.setData(curData.get("rightData"))
    #right.invalidateAllRows()
    @setGridErrorFormatting(right)
    @setGridStyle(right)
    right.render()
    if (resetColumns)
      right.resizeCanvas()
      left.resizeCanvas()
    Ember.run.scheduleOnce("afterRender", =>
      @resizeWidth()
      @resizeHeight()
    )

    @setRenderedGridEvents()
    #@setExtraSpace()

  setGridStyle: (grid) ->
    numEmptyRows = @get("parentController.activeModel.dataDriver.numEmptyRows")
    if numEmptyRows <= 0
      grid.setCellCssStyles("filler", {})
      return
    fillerStyleObj = {}
    columns = grid.getColumns()
    for column in columns
      fillerStyleObj[column.id] = "filler-cell"
    allStyles = {}
    totalRows = @get("parentController.activeModel.dataDriver.leftGrid.length")
    for i in ([(totalRows - 1)..(totalRows - numEmptyRows)])
      allStyles[i.toString()] = fillerStyleObj
    grid.setCellCssStyles("filler", allStyles)




  setBoundEvents: (left, right) ->
    controller = @
    @setParallelScroll(left, right)
    @setArrowKeySwitch(left, right)

    @setColumnHeaderMenu()
    @setCellDrawEvents(right)
    @setSortMenuHover()
    @get("parentController").setSortEvents()
    @setCellClickEvents(left, right)
    @setRowHover(left, right)

  setRenderedGridEvents: ->
    Ember.run.next(=>
      # TODO: add any grid rendered funcs here
      # TODO: uncomment to include conditionally blocked
      #@drawConditionallyBlocked()
      #$(".slick-cell").hover( (event) ->
      #  console.log event
      #)
    )

  setSortMenuHover: ->
    parent = @get("parentController")
    $(".grid-container").on("mouseenter", ".slick-header-menuitem", (event) ->
      if $(event.target).text() == "Sort"
        $sortMenu = parent.constructSortMenu(event)
        $sortMenu.appendTo(".outer-grid-container")
        $("body").one("click", ->
          Ember.run.next(->
            $(".sort-menu").remove()
          )
        )
      else
        $(".sort-menu").remove()
    )

  setParallelScroll: (left, right) ->
    controller = @
    left.onScroll.subscribe( (event, args) ->
      $("#right-grid .slick-viewport").scrollTop($("#left-grid .slick-viewport").scrollTop())
    )
    right.onScroll.subscribe( (event, args) ->
      $("#left-grid .slick-viewport").scrollTop($("#right-grid .slick-viewport").scrollTop())
    )

    left.onColumnsResized.subscribe( (event, args) ->
      controller.resizeWidth()
      args.grid.resizeCanvas()
    )
    right.onColumnsResized.subscribe( (event, args) ->
      controller.resizeWidth()
      args.grid.resizeCanvas()
    )
    right.onActiveCellChanged.subscribe( ->
      left.resetActiveCell()
    )
    left.onActiveCellChanged.subscribe( ->
      right.resetActiveCell()
    )

  resizeMenu: (event) ->
    Ember.run.next(->
      $(".slick-header-menu").width($(event.target).width())
    )

  setColumnHeaderMenu: ->
    context = @
    parent = @get("parentController")
    @leftHeaderMenu.onBeforeMenuShow.subscribe( (event, args) ->
      context.resizeMenu(event)
      parent.set("activeColumn", args.column)
      $(".sort-menu").remove()
      menu = args.menu
      context.removeErrorsFromMenu(menu.items)
      isSubject = (args.column.id == "subject-id")
      parent.checkForSubjectSort(isSubject)
    )

    @headerMenu.onBeforeMenuShow.subscribe( (event, args) ->
      context.resizeMenu(event)
      parent.set("activeColumn", args.column)
      menu = args.menu
      #menu.items = parent.get("activeModel.defaultColumnHeader").menu.items
      context.removeErrorsFromMenu(menu.items)
      isSubject = false
      parent.checkForSubjectSort(isSubject)
      questionID = args.column.id
      numErrors = parent.get("activeModel.answerErrors").numActiveErrorsForQuestion(questionID)
      if numErrors > 0
        text = "Fix #{numErrors} Errors"
        newItems = [
          {
            title: "<div class='custom-menu-item header-menu-errors'>#{text}</div> ",
            command: "fixErrors"
          }
        ]
        menu.items = newItems.concat(menu.items)
        unless parent.get("activeModel.isCompleted")
          for item in menu.items
            if item.command != "filterInQuestion" and item.command != openSortMenu
              title = $(item.title)
              if title.length == 0
                continue
              title.addClass("needs-all-data")
              item.title = title[0]
      question = parent.getQuestionFromID(args.column.id)
      if Ember.isEmpty(question)
        menu.items = context.getOtherQuestionMenu(menu.items)
    )


    @headerMenu.onCommand.subscribe( (event, args) ->
      context.handleMenuCommand(context, event, args)
    )

    @leftHeaderMenu.onCommand.subscribe( (event, args) ->
      context.handleMenuCommand(context, event, args)
    )

  getOtherQuestionMenu: (menuItems) ->
    retArr = []
    for item, i in menuItems
      switch item.command
        when "filterInQuestion", "openSortMenu"
          retArr.push(item)
    return retArr

  handleMenuCommand: (context, event, args) ->
    parent = context.get("parentController")
    isCompleted = parent.get("activeModel.isCompleted")
    switch args.command
      when "filterInQuestion"
        parent.set("curFilterString", "")
        #context.requestNewRender()
        Ember.run.next(->
          parent.set("curFilterVariable", args.column.field)
          $(".filter-text").focus()
          $(window).scrollTop(0)
        )
      when "setQuestionTypeAndConfig", "renameQuestion"
        unless isCompleted
          return
        question = parent.getQuestionFromID(args.column.id)
        questionCopy = question.copy()
        questionCopy.set("formStructure", parent.get("activeModel.formStructure"))
        parent.send("openDialog", "set_data_format", questionCopy, "set_data_format_dialog")
        if args.command == "setQuestionTypeAndConfig"
        else
          $(document).one("opened", "[data-reveal]", (->
              $(".question-variable-name:eq(0)").focus()
              $(".question-variable-name:eq(0)").select()
            )
          )
      when "fixErrors"
        questionID = args.column.id
        parent.openTargetDataCleanup(questionID, null)
      when "deleteQuestion"
        question = parent.getQuestionFromID(args.column.id)
        parent.send("openDialog", "confirm_delete_question", question)
      when "openSortMenu"
        $(".sort-menu").remove()
      when "secondaryIdSettings"
        parent.send("editSecondaryId")
        console.log "doing other stuff"
      else
        console.log "unknown command: #{args.command}"

  removeErrorsFromMenu: (menuItems)->
    if menuItems.length == 0
      return
    firstItem = menuItems[0]
    if firstItem.command == "fixErrors"
      menuItems.shift()


  setArrowKeySwitch: (left, right) ->
    right.onKeyDown.subscribe( (event, args) ->
      if (event.keyCode == 37 and args.cell == 0)
        right.resetActiveCell()
        left.setActiveCell(args.row, left.getColumns().length - 1)
        left.focus()
    )
    left.onKeyDown.subscribe( (event, args) ->
      if (event.keyCode == 39 and args.cell == left.getColumns().length - 1)
        left.resetActiveCell()
        right.setActiveCell(args.row, 0)
        right.focus()
    )

  setCellClickEvents: (left, right) ->
    controller = @get("parentController")
    right.onDblClick.subscribe( (event, args) ->
      $cell = $(event.target)
      if $cell.hasClass("cell-error")
        questionID = controller.getQuestionIDFromCell(right, args.cell)
        responseID = controller.getResponseIDFromCell(args.row)
        controller.openTargetDataCleanup(questionID, responseID)
    )


  setRowHover: (left, right) ->
    $(".outer-grid-container").on("mouseenter", ".slick-cell", (event) ->
      $(".slick-row.highlighted").removeClass("highlighted")
      cell = right.getCellFromEvent(event)
      if Ember.isEmpty(cell)
        cell = left.getCellFromEvent(event)
      leftRow = $(left.getCellNode(cell.row, 0)).parent()
      rightRow = $(right.getCellNode(cell.row, 0)).parent()
      leftRow.addClass("highlighted")
      rightRow.addClass("highlighted")
    )
    $(".outer-grid-container").on("mouseleave", ".slick-viewport", ->
      $(".slick-row.highlighted").removeClass("highlighted")
    )
    # TODO wrap in function below
    # tooltips
    $(".outer-grid-container").on("mouseenter", ".slick-cell, .slick-header-column", (event) ->
      target = $(event.target)
      if target.innerWidth() < target[0].scrollWidth
        text = target.text()
        if target.hasClass("slick-header-column")
          text = target.find("span").text()
        target.attr("title", text)
    )


  setCellDrawEvents: (grid) ->
    controller = @
    # TODO: implement this to draw gray conditionally blocked cells
    #grid.onViewportChanged.subscribe( (event, args) ->
    #  controller.drawConditionallyBlocked()
    #)

  drawConditionallyBlocked: ->
    $(".right-pane .slick-cell").each(->
      if $(this).text() == "\u200D" and !($(this).hasClass("conditionally-blocked-cell"))
        $(this).addClass("conditionally-blocked-cell")
    )

  setGridErrorFormatting: (grid) ->
    activeModel = @get("parentController.activeModel")
    cellCssFormatting = {}
    if Ember.isEmpty(activeModel.get("dataDriver.data"))
      return
    errors = activeModel.get("answerErrors.errorsByResponse")
    for responseObj, i in activeModel.get("dataDriver.data")
      for answerObj in responseObj
        if "responseID" of answerObj
          responseID = answerObj.responseID
          if responseID of errors
            errorClassObj = {}
            for errorVar in errors[responseID]
              unless errorVar.canceled or errorVar.isActive == false
                errorClassObj[errorVar.questionID] = "cell-error"
            cellCssFormatting[i] = errorClassObj
          break
    grid.setCellCssStyles("errors", cellCssFormatting)
    $(".outer-grid-container .error-bubble").remove()
    for questionID, errors of activeModel.get("answerErrors.errorsByQuestion")
      errorCount = activeModel.get("answerErrors").numActiveErrorsForQuestion(questionID)
      if errorCount > 0
        errorDiv = $("<div></div>", {
          class: "error-bubble",
          text: errorCount.toString()
        })
        $("[id$=#{questionID}]").prepend(errorDiv)


  resizeWidth: ->
    scrollbarAdjustment = 2
    rightScrollbarAdjustment = 16
    if $(".right-pane .grid-canvas").width() > $(".right-pane .slick-viewport").width()
      rightScrollbarAdjustment = 16
    leftWidth = $("#left-grid .grid-canvas").width()
    rightWidth = $("#right-grid .grid-canvas").width()
    containerWidth = $(".outer-grid-container").width() - 15
    newLeftWidth = Math.min(containerWidth / 2, leftWidth) + scrollbarAdjustment
    newRightWidth = Math.min(containerWidth - newLeftWidth - 9, rightWidth + rightScrollbarAdjustment)
    $(".left-pane").width(newLeftWidth)
    $(".right-pane").width(newRightWidth)
    $(".grid-spacer").css("left", newLeftWidth + 13)
    $(".right-pane").css("left", $(".left-pane").width() + 17)
    @get("parentController.tabHandler").setIsWiderThanGrid()


  resizeHeight: ->
    numRows = Math.max(
      @get("parentController.displayedRows"),
      @get("parentController.activeModel.dataDriver.MIN_ROW_COUNT")
    )
    headerAdjustment = 105
    headerHeight = 40
    rowHeight = 30
    minGridHeight = 350
    scrollBarHeight = 12
    maxGridHeight = $(window).height() - headerAdjustment
    contentHeight = numRows * rowHeight + headerHeight
    spacerHeight = contentHeight;

    if contentHeight < maxGridHeight
      maxGridHeight = contentHeight
    else
      spacerHeight = maxGridHeight
    finalHeight = Math.max(maxGridHeight, minGridHeight)

    outerGridContainer = $(".outer-grid-container")
    innerGridContainers = $(".grid-container")
    spacerDiv = $(".grid-spacer")
    outerGridContainer.height(finalHeight)
    innerGridContainers.height(finalHeight)
    spacerDiv.height(spacerHeight)
    try # will occasionally cause error on transition away
      @get("rightGrid").resizeCanvas()
      @get("leftGrid").resizeCanvas()
    hasSideScroll = ($(".right-pane .grid-canvas").height() >= $(".right-pane .slick-viewport").height())
    hasBottomScroll = ($(".right-pane .grid-canvas").width() >= $(".right-pane .slick-viewport").width())
    if hasSideScroll and hasBottomScroll
      $(".right-pane .slick-viewport").height($(".right-pane .slick-viewport").height() + scrollBarHeight + 2)
      $(".right-pane").height($(".right-pane").height() + scrollBarHeight + 2)
    else
      $(".right-pane .slick-viewport").height($(".right-pane .slick-viewport").height() + 2)
      $(".right-pane").height($(".right-pane").height() + 2)
    $(".grid-blocked").height($(window).height() - headerAdjustment)


  setGridToEmpty: ->
    unless Ember.isEmpty(@get("rightGrid")) or Ember.isEmpty(@get("leftGrid"))
      @get("leftGrid").setData([])
      @get("leftGrid").invalidate()
      @get("rightGrid").setData([])
      @get("rightGrid").invalidate()
