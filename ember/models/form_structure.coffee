LabCompass.FormStructure = LD.Model.extend
  id: null

  name: LD.attr "string"
  description: LD.attr "string"
  isManyToOne: LD.attr "boolean", default: false
  secondaryId: LD.attr "string", default: null
  isSecondaryIdSorted: LD.attr "boolean", default: false
  colorIndex: LD.attr "number"

  color: (->
    ["#31AFF1", "#DC2004"," #278D0C", "#A82598", "#000000", "#FDA1E4", "#0A2C62", "#781312", "#FCAB9D", "#C82868", "#C82868", "#31AFF1"][@get('colorIndex')]
  ).property 'colorIndex'

  shortName: (->
    str = @get("name")
    length = str.length
    if length > 27
       str = str.substring(0, 27) + "..."
    else
      return str
  ).property("name")

  projectShortName: (->
    str = @get("name")
    length = str.length
    if length > 42
      str = str.substring(0,42) + "..."
    else
      return str
  ).property("name")

  formShortName: (->
    str = @get("name")
    length = str.length
    if length > 39
      str = str.substring(0,39) + "..."
    else
      return str
  ).property("name")

  questions: LD.hasMany "FormQuestion"

  questionSorting: ["sequenceNumber"]
  sortedQuestions: Ember.computed.sort "questions", "questionSorting"


  responsesCount: LD.attr "number"
  lastEdited: LD.attr "string"

  formattedLastEdited: (->
    moment(@get "lastEdited").format "h:mm A [on] M/D/YYYY"
  ).property "lastEdited"

  userPermissions: LD.hasOne "FormLevelPermissions"

  curPage: 0

  questionNumberAndDependencyAssigner: (->
    questions = @get("sortedQuestions")
    LabCompass.QuestionNumberAssigner(questions)
    LabCompass.DependentQuestionIdentifier(questions)
  ).observes("sortedQuestions.[]").on("init")

  #structures for grid
  hasNoData: false
  allCompleted: false
  grid: []
  header: []
  subject_dates: {}