#not displayed anywhere but the meaningful logic behind the combo-box component
#controls firing of all the response lookup events based on combo-box input and interaction
LabCompass.ComboBoxLogic = Ember.Object.extend

  allOptions: []
  allSortedOptions: Ember.computed.sort "allOptions", (a, b) ->
    Ember.compare a.toLowerCase(), b.toLowerCase()

  allOptionsObjects: Ember.computed.map "allSortedOptions", (opt) ->
    LabCompass.ComboBoxOption.create value: opt

  #allOptionsObjects:(->
  #  try start = new Time().getTime()
  #  allSortedOptions = @get "allSortedOptions"
  #  objects = []
  #  allSortedOptions.map (opt)->
  #    objects.push (LabCompass.ComboBoxOption.create(value: opt))
  #  try end = new Time().getTime()
  #  return objects
  #).property('allSortedOptions')

  filter: ""
  lowercaseFilter: ( ->
    if @get("filter") == null
      ""
    else
      (@get("filter") || "").toLowerCase()
  ).property "filter"



  allowCreate: true
  canCreateNewOption: ( ->
    filter = @get "lowercaseFilter"
    options = @get "allOptionsObjects"

    @get("allowCreate") && !Ember.isEmpty(filter.trim()) && !options.findBy "lowercaseValue", filter
  ).property "lowercaseFilter", "allOptions"

  cachedOptions: null


  options: []

  setOptions: ( ->
    allOptions = @get "allOptionsObjects"
    filter = @get "lowercaseFilter"
    previousFilter = @get 'previousFilter'
    @set 'previousFilter', filter
    createNewOpts = []
    exactMatch = null
    unless filter == previousFilter
      filtered = allOptions.filter (option) ->
        if option.get('lowercaseValue') == filter
          exactMatch = option
          return false
        else
          option.get("lowercaseValue").indexOf(filter) != -1
      if exactMatch
        filtered.insertAt 0, exactMatch
    else
      cached = @get 'cachedOptions'
      if !Ember.isEmpty cached
        filtered = cached
      else
        filtered = allOptions
    if @get("canCreateNewOption") && filter != previousFilter
      filtered.insertAt 0, LabCompass.ComboBoxOption.create
        value: @get "filter"
        displayValue: "+ Create New"
    @set 'cachedOptions', filtered
    @set 'options', filtered
  ).observes("allOptions", "lowercaseFilter", "canCreateNewOption")

  partial_list: false
  short_options: []

  setShortOptions: (->
    a = @get("options")
    if a.length > 300
      @set 'partial_list', true
      @set("short_options", a.slice(0,300))
    else
      @set 'partial_list', false
      @set("short_options", a)
  ).observes("options")
  selectedIndex: 0
  selectedOption: ( (_, option)->
    options = @get "options"
    if arguments.length > 1
      newIndex = options.indexOf option
      if newIndex >= 0
        @set "selectedIndex", newIndex
    options.objectAt @get "selectedIndex"
  ).property "selectedIndex"

  selectionUpdater: ( ->
    selectedOption = @get("selectedOption")
    unless selectedOption == undefined
      @get("options").forEach (option) =>
        theOne = option == selectedOption
        option.set "selected", theOne
  ).observes("selectedOption").on "init"

  resetSelectionAfterFilter: (->
    index = if @get("options").length > 1 && @get "canCreateNewOption"
      1
    else
      0
    if @get("selectedOption") != @get("options").objectAt(index)
      @set "selectedOption", @get("options").objectAt(index)
  ).observes "lowercaseFilter", "options.[]", "canCreateNewOption"

  selectNext: ->
    index = @get "selectedIndex"
    maxIndex = @get("options").length - 1
    @set "selectedIndex", Math.min(maxIndex, index + 1)

  selectPrevious: ->
    index = @get "selectedIndex"
    @set "selectedIndex", Math.max(0, index - 1)

LabCompass.ComboBoxOption = Ember.Object.extend

  value: null
  selected: false
  displayValue: Ember.computed.oneWay("value")

  lowercaseValue: (->
    if @get("value") == null
      ""
    else
      (@get "value" || "").toLowerCase()
  ).property "value"

LabCompass.register "combo-box:logic", LabCompass.ComboBoxLogic, singleton: false
