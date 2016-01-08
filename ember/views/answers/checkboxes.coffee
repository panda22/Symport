LabCompass.AnswerCheckboxesView = Ember.View.extend
  layoutName: "answers/default_layout"

LabCompass.AnswerCheckboxesEditor = LabCompass.AnswerCheckboxesView.extend
  templateName: "answers/edit_checkboxes"

LabCompass.AnswerCheckboxesViewer = LabCompass.AnswerCheckboxesView.extend
  templateName: "answers/view_checkboxes"