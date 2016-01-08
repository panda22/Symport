LabCompass.FormData = LD.Model.extend
  formID: null
  formName: ""
  leftData: [] # body
  rightData: [] # body
  dataDriver: null # does all grid algorithms. in ember/logic
  leftColumns: [] # header
  rightColumns: [] # header
  answerErrors: LD.hasOne "formDataErrors"
  secondaryId: null
  canView: true

  isInitActive: false
  color: ""

  displayPopup: true

  initErrors: (errorObjs, numErrors) ->
    @get("answerErrors").setup(errorObjs, numErrors)

  formStructure: null

  isCompleted: false
  initialSize: 250 # gets set dynamically from backend controller value

  filterVariable: ""
  filterString: ""

  sortVariable: "Subject ID"
  sortType: null
  sortTypeStr: ""

  hasNoData: false

  defaultColumnHeader: ->
    menu:
      items: [
        {
          title: "<div class='custom-menu-item edit-item'>Edit/Rename</div>"
          command: "renameQuestion"
        },
        {
          title: "<div class='custom-menu-item format-item'>Set Data Format</div>"
          command: "setQuestionTypeAndConfig"
        },
        {
          title: "<div class='custom-menu-item filter-item'>Filter</div>"
          command: "filterInQuestion"
        },
        {
          title: "<div class='custom-menu-item open-sort-menu'>Sort</div>"
          command: "openSortMenu"
        },
        {
          title: "<div class='custom-menu-item delete-item'>Delete</div>"
          command: "deleteQuestion"
        }
      ]

  subjectColumnHeader:
    menu:
      items: [
        #{
        #  title: "<div class='custom-menu-item'>Edit/Rename</div>"
        #  command: "renameQuestion"
        #},
        {
          title: "<div class='custom-menu-item filter-item'>Filter</div>"
          command: "filterInQuestion"
        },
        {
          title: "<div class='custom-menu-item open-sort-menu'>Sort</div>"
          command: "openSortMenu"
        }
      ]

  secondaryColumnHeader:
    menu:
      items: [
        #{
        #  title: "<div class='custom-menu-item'>Edit/Rename</div>"
        #  command: "renameQuestion"
        #},
        {
          title: "<div class='custom-menu-item filter-item'>Filter</div>"
          command: "filterInQuestion"
        },
        {
          title: "<div class='custom-menu-item open-sort-menu'>Sort</div>"
          command: "openSortMenu"
        },
        #{
        #  title: "Delete"
        #  command: "deleteInstance"
        #},
        {
          title: "<div class='custom-menu-item settings-item'>Secondary ID Settings</div>"
          command: "secondaryIdSettings"
        }
      ]




  SetDriverFilterAndSort: (->
    @set("dataDriver.filterVariable", @get("filterVariable"))
    @set("dataDriver.filterString", @get("filterString"))
    @set("dataDriver.comparatorFunc", @get("sortType"))
    @set("dataDriver.sortVariable", @get("sortVariable"))
  ).observes("filterVariable", "filterString", "sortType", "sortVariable")


  loadHeaders: (left, right) ->
    if left == null or right == null
      return
    @addLeftHeaderSettings(left)
    @addDefaultSettingsToHeader(right)
    @set("leftColumns", left)
    @set("rightColumns", right)


  loadData: (data, leftColumns) ->
    if Ember.isEmpty(data)
      @set("hasNoData", true)
    else
      @set("hasNoData", false)
    if data == null
      data = []
    @get("dataDriver").initialize(data, leftColumns)
    @set("leftData", @get("dataDriver.leftGrid"))
    @set("rightData", @get("dataDriver.rightGrid"))

  addRemainingData: (newData) ->
    @get("dataDriver").addData(newData)
    @set("leftData", @get("dataDriver.leftGrid"))
    @set("rightData", @get("dataDriver.rightGrid"))
    @set("isCompleted", true)

  addColumn: (name, field, id, isLeft=false) ->
    obj = {
      name: name,
      field: field,
      id: id
    }
    if isLeft
      @get("leftColumns").push(obj)
      @addLeftHeaderSettings(@get("leftColumns"))
      @get("dataDriver.leftColumnKeys").push(field)
    else
      @get("rightColumns").push(obj)
      @addDefaultSettingsToHeader(@get("rightColumns"))

  reconstructGrids: ->
    @get("dataDriver").constructGrids()
    @set("leftData", @get("dataDriver.leftGrid"))
    @set("rightData", @get("dataDriver.rightGrid"))

  removeExcessRows: ->
    if @get("rightData").length > @initialSize
      @set("isCompleted", false)
      @get("dataDriver").truncate(@initialSize)

  addDefaultSettingsToHeader: (header) ->
    for column in header
      column.header = @defaultColumnHeader()

  addLeftHeaderSettings: (header) ->
    if header.length == 0
      return
    header[0].header = @subjectColumnHeader
    if header.length > 1
      header[1].header = @secondaryColumnHeader

  updateFilter: (->
    if @get("isCompleted") or @get("filterVariable") != ""
      return
    @get("dataDriver").updateFilter(@get("filterString"), @get("filterVariable"))
    @set("leftData", @get("dataDriver.leftGrid"))
    @set("rightData", @get("dataDriver.rightGrid"))
  ).observes("isCompleted", "filterString", "filterVariable")

  updateFormStructure: (newForm) ->
    @setProperties({
      formStructure: newForm,
      formName: newForm.get("name"),
      formID: newForm.id,
      secondaryId: newForm.get("secondaryId"),
      description: newForm.get("description")
    })


  deleteColumn: (targetQuestion) ->
    for question, i in @get("formStructure.questions.content")
      seqNum = question.get("sequenceNumber")
      if seqNum > targetQuestion.get("sequenceNumber")
        question.set("sequenceNumber", seqNum - 1)
    @get("formStructure.questions").removeObject(targetQuestion)
    for column, i in @get("rightColumns")
      if column.id == targetQuestion.id
        @get("rightColumns").splice(i, 1)
        break
    questionErrors = @get("answerErrors.errorsByQuestion")[targetQuestion.id]
    unless Ember.isEmpty(questionErrors)
      for errorObj in questionErrors
        errorObj.canceled = true

  deleteSecondaryIdColumn: ->
    @get("dataDriver.leftColumnKeys").length = 1
    @get("leftColumns").length = 1

  updateAnswersForQuestion: (newAnswerHash, varName) ->
    @get("dataDriver").updateAnswersForQuestion(newAnswerHash, varName)





