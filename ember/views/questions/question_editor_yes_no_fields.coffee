LabCompass.QuestionEditorYesNoFields = Ember.View.extend
  layoutName: "questions/default_layout"
  templateName: "questions/yesno"

  canEditCode: false

  actions:
    toggleEditCodes: ->
      @set("canEditCode", !@canEditCode)
      @$().find(".edit-question-code").attr("disabled", !@canEditCode)
      if @get("canEditCode")
        @$().find(".edit-code-header").html("Done")
      else
        @$().find(".edit-code-header").html("Edit Codes")
