LabCompass.QuestionEditorOptionsFields = Ember.View.extend
  layoutName: "questions/default_layout"
  templateName: "questions/options"

  textbox_var_name: null

  change_in_other_var_textbox: (->
    for config in @get("question.config.selections.content")
      if config.get('otherOption')
        config.set('otherVariableName', @get('textbox_var_name'))
  ).observes 'textbox_var_name'

  otherConfig: null

  hasOtherOption: (->
    for config in @get("question.config.selections.content")
      if config.get('otherOption')
        @set 'otherConfig', config
        @set 'textbox_var_name', config.get('otherVariableName')
        return true
    Ember.run.next =>
      $("#textbox-var-name")[0].style.display = "none"
    return false
  ).property 'question.config.selections.content'

  showAddOtherOption: (->
    @get('question.type') != "dropdown"
  ).property 'question.type'

  removeOtherOptions: (->
    unless @get 'showAddOtherOption'
      for config in @get("question.config.selections.content")
        if config.get('otherOption')
          @get("question.config.selections").removeObject config
          return      
  ).observes "showAddOtherOption"

  canEditCode: false

  actions:
    addOption: ->
      i = -1
      found = i
      for option in $('.option-value')
        i = i + 1
        if $(option).is(":focus")
          found = i
      if found == -1
        found = i
      selection = @get("question.config.selections").insertAt(found + 1, {isNew: true})
      codeVal = @get("question.config.selections.content").length.toString()
      selection.get("content")[found + 1].set("code", codeVal)
      Ember.run.next(=>
        @$().find(".edit-question-code").attr("disabled", !@canEditCode)
        $(@$().find(".option-value")[found+1]).focus()
      )
      #Ember.run.next(=>
      #  @$().find(".edit-question-code:eq(#{found + 1})").val(codeVal)
      #)
    addTextOption: ->
      i = -1
      found = i
      for option in $('.option-value')
        i = i + 1
        if $(option).is(":focus")
          found = i
      if found == -1
        found = i
      selection = @get("question.config.selections").insertAt(found + 1, {isNew: true, otherOption: true, value: "Other, Please Specify"})
      @set 'textbox_var_name', (@get('question.variableName') + "_other_textbox")
      codeVal = @get("question.config.selections.content").length.toString()
      selection.get("content")[found + 1].set("code", codeVal)
      Ember.run.next(=>
        @$().find(".edit-question-code").attr("disabled", !@canEditCode)
        $("#addTextOption")[0].disabled = true
        $("#textbox-var-name")[0].style.display = "block"
        @$().find(".option-value:last").focus()

      )

    toggleEditCodes: ->
      @set("canEditCode", !@canEditCode)
      @$().find(".edit-question-code").attr("disabled", !@canEditCode)
      if @get("canEditCode")
        @$().find(".edit-code-header").html("Done")
      else
        @$().find(".edit-code-header").html("Edit Codes")

    removeOption: (opt) ->
      if opt.get('otherOption')
        Ember.run.next =>
          @set "textbox_var_name", ""
          $("#addTextOption")[0].disabled = false
          $("#textbox-var-name")[0].style.display = "none"
      @get("question.config.selections").removeObject opt
      #Ember.run.next =>
       # $('.tooltip').each ->
        #  this.setAttribute('style', 'display: none')