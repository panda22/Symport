LabCompass.QuestionImportingDialogController = LabCompass.QuestionDialogController.extend
  needs: 'projectImport'
  formStructure: Ember.computed.alias('controllers.projectImport.adding_question_form')
