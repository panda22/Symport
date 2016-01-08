LabCompass.AnswerTextEditor = Ember.View.extend
  layoutName: "answers/default_layout"
  templateName: "answers/edit_text"

  isLongField: ( ->
    @get("answer.question.config.size") == "large"
  ).property "answer.question.config.size"