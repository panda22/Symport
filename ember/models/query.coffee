LabCompass.Query = LD.Model.extend
  id: null
  projectID: LD.attr "string", default: null
  name: LD.attr "string", default: ""
  ownerName: LD.attr "string", default: ""
  created: LD.attr "date"
  editorName: LD.attr "string"
  edited: LD.attr "date"
  conjunction: LD.attr "string", default: "and"
  queryParams: LD.hasMany "queryParam"
  queriedForms: LD.hasMany "queryFormStructure"
  isShared: LD.attr "boolean", default: false
  canEditPermissions: LD.attr "boolean", default: false
  canDelete: LD.attr "boolean", default: false
  isChanged: LD.attr "boolean", default: false
  changeMessage: null

  lastUpdatedString: (->
    if Ember.isEmpty(@get("editedTimeStampString")) or Ember.isEmpty(@get("editorName"))
      return ""
    @get("editedTimeStampString") + " by " + @get("editorName")
  ).property "editedTimeStampString", "editorName"

  createdString: ( ->
    if Ember.isEmpty(@get("isShared")) or Ember.isEmpty(@get("ownerName"))
      return ""
    if @get("ownerName") == "Me"
      if @get("isShared")
        "Created by Me | Viewable by Everyone"
      else
        "Created and Viewable by Me"
    else
      "Created by " + @get("ownerName") + " | Viewable by Everyone"
  ).property "ownerName", "isShared"


  editedTimeStampString: (->
    if Ember.isEmpty(@get("edited"))
      return ""
    date = new Date(@get("edited"))
    amPmString = "AM"
    if date.getHours() > 12
      amPmString = "PM"
    hourString = date.getHours() % 12
    if hourString == 0
      hourString == 12
    minuteString = date.getMinutes()
    if minuteString < 10
      minuteString = "0" + minuteString
    dateStr = date.getMonth() + "/" + date.getDay() + "/" + date.getFullYear()
    timeStr = hourString + ":" + minuteString + " " + amPmString
    "Last updated on " + dateStr + " at " + timeStr
  ).property "edited"

  compare: (otherModel) ->
    @modelCompare(@, otherModel)


  modelCompare: (model, otherModel) ->
    for attr in model.attributes()
      if attr.name == "errors"
        continue
      if Ember.typeOf(attr.value) == "instance" # LD model
        if attr.value.content # hasMany relationship with LD model
          if attr.value.content.length != otherModel.get(attr.name).content.length
            return false
          for i in [0...attr.value.content.length]
            thisInstance = attr.value.content[i]
            otherInstance = otherModel.get(attr.name).content[i]
            if @modelCompare(thisInstance, otherInstance) == false
              return false
        else # hasOne relationship with LD model
          if @modelCompare(attr.value, otherModel.get("attr.name")) == false
            return false
      else if attr.value != otherModel.get(attr.name) # basic value type
        if @isNullCompareValue(attr.value) and @isNullCompareValue(otherModel.get(attr.name))
          continue
        #console.error attr.name + " | " + attr.value + " | " + otherModel.get(attr.name)
        return false
    return true

  isNullCompareValue: (val) ->
    if Ember.typeOf(val) == "undefined" or val == null or val == ""
      return true
    return false






