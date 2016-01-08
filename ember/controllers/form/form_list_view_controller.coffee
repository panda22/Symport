LabCompass.FormListViewController = Ember.ObjectController.extend LabCompass.WithProject,

  hoverId: Ember.computed(->
    formId = @get("id")
    hoverName = "hover" + formId
    return hoverName
  )

  style: (->
    "border-left: 4px solid #{@get('model.color')}"
  ).property('model.color')

  resizeDataExportPopup: ->
    document.getElementById('data-export-popup').style.overflowY = "auto"

  actions:
    editFormStructure: ->
      @send "loadingOn"
      @transitionToRoute "form.build", @get('id')

    confirmDeleteFormStructure: ->
      @send "openDialog", "confirm_delete_form", @get('model'), "confirmDeleteForm", this # provide current pseudo-context

    renameFormStructure: ->
      @send "openDialog", "rename_form_structure", @get('model'), "renameFormStructure"

    editSecondaryId: ->
      @set("model.manyToOneLock", false)
      @set("model.manyToOneWarning", false)
      if @get("model.isManyToOne")
        @storage.getMaxInstancesInFormStructure(@get("model.id"))
        .then (numInstances) =>
          if numInstances > 1
            @set("model.manyToOneLock", true)
          else if numInstances == 1
            @set("model.manyToOneWarning", true)
          @send "openDialog", "secondary_id_details", @get('model'), "secondaryIdDetails"          
      else
        @send "openDialog", "secondary_id_details", @get('model'), "secondaryIdDetails"

    deleteFormStructure: ->
      @send "closeDialog"

      formId = @get("id")
      $("#" + formId).fadeOut(1000, "linear")

      window.setTimeout =>
        @storage.deleteFormStructure @get("project"), @get('model')
      , 1000

    viewFormResponses: ->
      @send "loadingOn"
      @transitionToRoute "responses", @get('id')

    export: ->
      #@send "openDialog", "form_import", @get('model'), "formImport"
      #return

      @send "openDialog", "confirm_download_responses", @get('model'), "downloadFormResponses"
      Ember.run.next =>
        $(document).on 'opened', =>
          document.getElementsByTagName("body")[0].style.overflow = "hidden"
          document.getElementById('data-export-popup').style.overflowY = "auto"

        $(window).on('resize', @resizeDataExportPopup) 


        $(document).on 'closed', =>
          document.getElementsByTagName("body")[0].style.overflow = "auto"
          $(document).off 'opened'
          $(window).off('resize', @resizeDataExportPopup)
