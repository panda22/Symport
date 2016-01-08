LabCompass.FormDataQuestionChangeHandler = Ember.Object.extend
  parent: null
  parentController: null
  formData: null
  curQuestion: null
  needsRender: false

  handleQuestionChanges: (oldQuestion, newQuestion) ->
    @set("needsRender", false)
    @set("curQuestion", newQuestion)
    @set("parentController", @get("parent.parentController"))
    @set("formData", @get("parentController.activeModel"))
    changes = []
    @getQuestionDifferences(oldQuestion, newQuestion, changes)
    @implementQuestionChanges(changes)
    return @get("needsRender")

  getQuestionDifferences: (originalQuestion, newQuestion, resultArray) ->
    for attr in newQuestion.attributes()
      if Ember.isEmpty(attr)
        continue
      if attr.name == "formStructure"
        continue
      if attr.name == "errors"
        continue
      if Ember.isEmpty(originalQuestion)
        resultArray.push({key: newQuestion.toString(), newVal: newQuestion, oldVal: originalQuestion})
        continue
      oldValue = originalQuestion.get(attr.name)
      if Ember.isEmpty(oldValue)
        continue
      if Ember.typeOf(attr.value) == "instance" # LD model
        if attr.value.content # hasMany relationship with LD model
          if Ember.isEmpty(oldValue.content) # hasMany relationship has been added
            resultArray.push({key: attr.name, newVal: attr.value, oldVal: oldValue})
            continue
          contentLength = Math.max(oldValue.content.length, attr.value.content.length)
          for i in [0...(contentLength)]
            newInstance = attr.value.content[i]
            oldInstance = oldValue.content[i]
            if Ember.isEmpty(attr.value.content[i]) or Ember.isEmpty(oldValue.content[i]) # different number of elements
              key = attr.name #"#{attr.name}\u200a#{i}"
              newVal = attr.value.content[i]
              oldVal = oldValue.content[i]
              resultArray.push({key: key, newVal: newVal, oldVal: oldVal})
            else # check for element changed
              @getQuestionDifferences(oldInstance, newInstance, resultArray)
        else # hasOne relationship with LD model
          @getQuestionDifferences(oldValue, attr.value, resultArray)

      else if attr.value != oldValue # basic value type
        if Ember.isEmpty(attr.value) and Ember.isEmpty(oldValue)
          continue
        #console.error attr.name + " | " + attr.value + " | " + otherModel.get(attr.name)
        resultArray.push({key: attr.name, newVal: attr.value, oldVal: oldValue})

  implementQuestionChanges: (changes) ->
    for changeObj in changes
      switch changeObj.key
        when "type"
          @changeQuestionType(changeObj.oldVal, changeObj.newVal)
        when "variableName"
          @changeVarName(changeObj.oldVal, changeObj.newVal)
        when "config"
          oldSelections = null
          unless Ember.isEmpty(changeObj.oldVal) or Ember.isEmpty(changeObj.oldVal.get("selections"))
            oldSelections = changeObj.oldVal.get("selections")
          newSelections = null
          unless Ember.isEmpty(changeObj.newVal) or Ember.isEmpty(changeObj.newVal.get("selections"))
            newSelections = changeObj.newVal.get("selections")

          @checkForOtherQuestion(oldSelections, newSelections)
        when "selections"
          oldContent = []
          newContent = []
          unless Ember.isEmpty(changeObj.oldVal)
            oldContent = [changeObj.oldVal]
          unless Ember.isEmpty(changeObj.newVal)
            newContent = [changeObj.newVal]
          @checkForOtherQuestion(oldContent, newContent)
        else
          if changeObj.key.indexOf("selections\u200a") != -1
            @checkForOtherQuestion([changeObj.oldVal], [changeObj.newVal])
          else



  changeQuestionType: (oldType, newType) ->
    # TODO: handle change in config separately

  checkForOtherQuestion: (oldConfigs, newConfigs) ->
    newOtherVarName = null
    oldOtherVarName = null
    unless Ember.isEmpty(oldConfigs)
      for config in oldConfigs
        if config.get("otherOption")
          oldOtherVarName = config.get("otherVariableName")
          break
    unless Ember.isEmpty(newConfigs)
      for config in newConfigs
        if config.get("otherOption")
          newOtherVarName = config.get("otherVariableName")
          break
    if newOtherVarName == null and oldOtherVarName == null
      return
    else if newOtherVarName != null and oldOtherVarName != null
      @changeOtherQuestion(oldOtherVarName, newOtherVarName)
    else if newOtherVarName != null
      @addOtherQuestion(newOtherVarName)
    else
      @removeOtherQuestion(oldOtherVarName)

  changeOtherQuestion: (oldVarName, newVarName) ->
    for column in @get("formData.rightColumns")
      if Ember.isEmpty(column)
        continue
      if column.name == oldVarName
        column.name = newVarName
        @set("needsRender", true)
        break

  addOtherQuestion: (newVarName) ->
    newColumn = {
      id: newVarName,
      name: newVarName,
      field: newVarName,
      header: @get("formData.defaultColumnHeader")
    }
    for column, i in @get("formData.rightColumns")
      if column.id == @get("curQuestion.id")
        @get("formData.rightColumns").splice(i+1, 0, newColumn)
        @set("needsRender", true)
        break

  removeOtherQuestion: (oldVarName) ->
    for column, i in @get("formData.rightColumns")
      if column.id == @get("curQuestion.id")
        @get("formData.rightColumns").splice(i+1, 1)
        @set("needsRender", true)
        break

  changeVarName: (oldName, newName) ->
    for column in @get("formData.rightColumns")
      if column.name == oldName
        # TODO: do I need to change the column field and the fields for all the cells in that column?
        column.name = newName
        @set("needsRender", true)
        return