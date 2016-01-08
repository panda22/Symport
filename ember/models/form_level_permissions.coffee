LabCompass.FormLevelPermissions = LD.Model.extend
  viewData: LD.attr "boolean"
  enterData: LD.attr "boolean"
  deleteForm: LD.attr "boolean"
  renameForm: LD.attr "boolean"
  downloadFormData: LD.attr "boolean"
  buildForm: LD.attr "boolean"
  viewPhiData: LD.attr "boolean"

  disableViewData: Ember.computed.not("viewData")
  disableDownloadFormData: (-> 
    !@get("downloadFormData") || !@get("viewData") 
  ).property "downloadFormData", "viewData"
  disableBuildForm: Ember.computed.not("buildForm")

  disableEnterData: Ember.computed.not("enterData")

  canOnlyViewData: (->
    if @get("viewData") and @get("disableBuildForm") and @get("disableEnterData")
      return true
  ).property 'enterData', 'viewData', 'buildForm'
