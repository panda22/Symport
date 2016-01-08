LabCompass.GridDataDriver = Ember.Object.extend
  rightGrid: []
  leftGrid: []
  filterVariable: ""
  filterString: ""
  leftColumnKeys: ""
  data: []

  sortVariable: ""
  comparatorFunc: null

  responseIDByRow: []

  MIN_ROW_COUNT: 10
  numEmptyRows: 0


  initialize: (newData, newLeftColumns) ->
    if Ember.isEmpty(newData)
      newData = []
    @set("data", newData)
    @set("leftColumnKeys", newLeftColumns)
    @constructGrids()

  addData: (newData) ->
    @set("data", @get("data").concat(newData))
    @constructGrids()

  truncate: (newLength) ->
    @get("data").length = newLength
    @get("rightGrid").length = newLength
    @get("leftGrid").length = newLength

  constructGrids: ->
    leftGrid = @get("leftGrid")
    rightGrid = @get("rightGrid")
    leftGrid = []
    rightGrid = []
    responseIDs = []
    if Ember.isEmpty(@get("data")) or @get("data.length") == 0
      @set("leftGrid", leftGrid)
      @set("rightGrid", rightGrid)
      return
    if @comparatorFunc != null and @sortVariable != ""
      @sortData(@sortVariable, @comparatorFunc)
    isAllData = (@filterVariable == "All Data")
    for row in @get("data")
      if Ember.isEmpty(row) or row.length == 0
        continue
      responseID = ""
      newLeftObj = {}
      newRightObj = {}
      rowIncluded = !isAllData
      for cell in row
        #if rowIncluded == false or rowIncluded == true
        #  continue
        tempVarName = cell.variableName
        if tempVarName == "subjectID"
          tempVarName = "Subject ID"
        if isAllData or tempVarName == @filterVariable
          lowerCell = cell.value.toLowerCase()
          lowerFilter = @filterString.toLowerCase()
          if lowerCell.indexOf(lowerFilter) == -1 and !isAllData #not found
            rowIncluded = false
          else if lowerCell.indexOf(lowerFilter) != -1 #found
            rowIncluded = true
        if @leftColumnKeys.indexOf(cell.variableName) != -1
          newLeftObj[cell.variableName] = cell.value
          if "responseID" of cell
            responseID = cell.responseID
        else
          newRightObj[cell.variableName] = cell.value
      if rowIncluded
        responseIDs[responseIDs.length] = responseID
        leftGrid[leftGrid.length] = newLeftObj
        rightGrid[rightGrid.length] = newRightObj
    if leftGrid.length < @MIN_ROW_COUNT
      @set("numEmptyRows", @MIN_ROW_COUNT - leftGrid.length)
      for i in [leftGrid.length...@MIN_ROW_COUNT]
        leftGrid[leftGrid.length] = {}
        rightGrid[rightGrid.length] = {}
    else
      @set("numEmptyRows", 0)
    @set("responseIDByRow", responseIDs)
    @set("leftGrid", leftGrid)
    @set("rightGrid", rightGrid)

  updateFilter: (newFilterString, newFilterVariable) ->
    @set("filterString", newFilterString)
    @set("filterVariable", newFilterVariable)
    @constructGrids()

  updateAnswersForQuestion: (newAnswerHash, varName) ->
    for row in @get("data")
      targetCell = null
      targetOtherCell = null
      targetResponseID = null
      for cell in row
        if "responseID" of cell
          if cell.responseID of newAnswerHash
            targetResponseID = cell.responseID
          else
            break
        if targetResponseID != null and newAnswerHash[targetResponseID].otherVariableName == cell.variableName
          targetOtherCell = cell
        if cell.variableName == varName
          targetCell = cell
      if targetCell == null or targetResponseID == null
        continue
      else
        targetCell.value = newAnswerHash[targetResponseID].answer
        if targetOtherCell != null
          targetOtherCell.value = newAnswerHash[targetResponseID].otherAnswer


  sortData: (varName, comparator=null, attribute="value") ->
    context = @
    #    newData = @get("data").sort( (a, b)->
    #      objA = context.getObjInRowByVariable(a, varName)
    #      objB = context.getObjInRowByVariable(b, varName)
    #      if objA == null or objB == null
    #        return 0
    #      if comparator == null
    #        return if (objA[attribute] < objB[attribute]) then 1 else -1
    #      else
    #        return comparator(objA, objB)
    #    )

    newData = @newSort(@get("data"), (a, b)->
      objA = context.getObjInRowByVariable(a, varName)
      objB = context.getObjInRowByVariable(b, varName)
      if comparator == null
        return 0
      else
        return comparator(objA, objB)
    )

    @set("data", newData)

  addColumnWithDefault: (varName, value) ->
    for row in @get("data")
      row.push({value: value, variableName: varName})



  getObjInRowByVariable: (row, varName) ->
    for obj in row
      if obj.variableName == varName
        return obj
    return null


  newSort: (array, comparatorFunc) ->
    len = array.length;
    if(len < 2)
      return array;
    pivot = Math.ceil(len/2);
    return @merge(@newSort(array.slice(0,pivot), comparatorFunc), @newSort(array.slice(pivot), comparatorFunc), comparatorFunc)

  merge: (left, right, comparatorFunc) ->
    result = [];
    while((left.length > 0) && (right.length > 0))
      compareVal = comparatorFunc(left[0], right[0])
      if compareVal > 0
        result.push(left.shift())
      else
        result.push(right.shift())

    result = result.concat(left, right)
    return result;