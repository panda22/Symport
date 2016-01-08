LabCompass.ConfirmDownloadCodebookController = Ember.Controller.extend LabCompass.WithProject,

  codebookLink: (->
    id = @get('project.id')
    "/projects/#{id}/codebook"
  ).property 'model.id'

  date: ""
  time: ""

  allFormsSelected: true

  init: ->
  	datetime = new Date()
  	date = datetime.toDateString()
  	@set 'date', date.slice(date.indexOf(" ")+1)
  	time  = datetime.toLocaleTimeString()
  	i = time.indexOf(" ")
  	@set 'time', (time.slice(0, i-3) + time.slice(i))

  additionalCodeBookFields: ["empty_code", "closed_code", "forms", "date", "time"]

  emptyCode: (->
    ""
  ).property "model"

  closedCode: (->
    ""
  ).property "model"

  showSelectAll: (->
    formArray = @get("model.queriedForms")
    #should never have a length of 0 because then the 
    #empty state message will be shown
    if formArray.get("length") == 1 
      return false
    else
      return true
  ).property("model.queriedForms")



  getExportFormsString: ->
    exportForms = {}
    for formObj in @get("model.exportCheckBoxes")
      exportForms[formObj.formID] = formObj.get("checked")
    return exportForms

  addCheckBoxObservers: (->
    unless Ember.isEmpty(@get("model"))
      for form in @get("model.queriedForms.content")
        form.addObserver("included", @, @observeFormCheckBox)
    if @get("model.queriedForms.length")
      @observeFormCheckBox(@get("model.queriedForms.firstObject"))
  ).observes("model")

  observeFormCheckBox: (formObj) ->
    allIncluded = true
    for form in @get("model.queriedForms.content")
      unless form.get("included")
        allIncluded = false
    @set("allFormsSelected", allIncluded)

  actions:
    selectAllExportForms: (add) ->
      for form in @get("model.queriedForms.content")
        form.set("included", add)
