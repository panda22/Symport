 LabCompass.AnswerTypeSpecificUI = LabCompass.DynamicContentView.extend
  answer: null
  editing: true
  enabled: true
  qBuilderPreview: null

  makeView: (->
    type = @get "answer.question.type"
    if @get "answer.filtered"
      fieldsView = @container.lookup "answerUI:filtered"
      unless fieldsView
        fieldsView = Ember.View.create
          template: Ember.Handlebars.compile "oh no!"
    else
      mode = if @get("editing") then "edit" else "view"
      fieldsView = @container.lookup "answerUI:#{type}.#{mode}"
      unless fieldsView
        fieldsView = Ember.View.create
          template: Ember.Handlebars.compile "Unsupported answer UI #{mode} for type #{type}"
    fieldsView.setProperties
      answer: @get "answer"
      disabled: !(@get "enabled")
      qBuilderPreview: @get("qBuilderPreview")
    
    Ember.run.next(=>
      if @get("qBuilderPreview") == true
        $("#"+@elementId).find("input, textarea, select").attr("tabindex", "-1")
    )
    @set "dynamicView", fieldsView
  ).observes("answer.question.type", "answer.filtered", "editing", "enabled").on "init"