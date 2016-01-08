LabCompass.QuestionEditorTypeSpecificFields = LabCompass.DynamicContentView.extend
  question: null
  isNew: true
  questionTypes: []
  structureMode: true

  classNames: ["typed-ui"]

  makeView: (->
    type = @get "question.type"
    fieldsView = @container.lookup "questionUI:#{type}"
    unless fieldsView
      fieldsView = Ember.View.create
        template: Ember.Handlebars.compile "Unsupported question type #{type}"
    fieldsView.setProperties
      question: @get "question"
      isNew: @get "isNew"
      disabled: !@get "isNew"
      questionTypes: @get "questionTypes"
      structureMode: @get "structureMode"
    @set "dynamicView", fieldsView
  ).observes("question.type", "isNew").on "init"
