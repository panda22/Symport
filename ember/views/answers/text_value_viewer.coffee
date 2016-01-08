LabCompass.AnswerTextValueViewer = Ember.View.extend
  layoutName: "answers/default_layout"
  templateName: "answers/view_text_value"

  formattedAnswer: Ember.computed.alias("answer.formattedAnswer")
