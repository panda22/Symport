#combo-box
#controls subjectID combo box selector dropdown
#deals with field focus, option showing and hiding, selection, and navigating
LabCompass.ComboBoxComponent = Ember.Component.extend

  classNames: ["combo-box"]

  value: ""

  old_value: ""

  options: Ember.computed.alias "logic.allOptions"

  allowCreate: Ember.computed.alias "logic.allowCreate"

  showOptions: false

  focusFirst: false

  #isDestroyed: false

  keepValueLength: (->
    val = @get "value"
    if val && val.length > 60
      @set 'value', @get("old_value")
    else
      @set 'old_value', val
  ).observes "value"


  update: (->

    clearTimeout(@get('typingTimer'))
    @set 'typingTimer', window.setTimeout =>
      if @get("logic")
        @set "logic.filter", @get "value"
    , 500 
  ).observes 'value'

  moveSelectionUp: ->
    @logic.selectPrevious()

  moveSelectionDown: ->
    @logic.selectNext()

  selectAndFire: ->
    value = @get "logic.selectedOption.value"
    @set "value", value
    @showOptions false
    @$("input").blur()
    # We need to wait for the "value" binding to propogate out before we fire the action.
    Ember.run.later =>
      @sendAction()


  fieldFocusIn: (highlight)->
    Ember.run.next =>
      @showOptions true
      if highlight
        @$("input").select()

  showing: false

  fieldFocusOut: ->
    time = 0
    time = 300 if @get('showing')
    Ember.run.later =>
      @showOptions false
    , time

  didInsertElement: ->
    if @get("focusFirst")
      @$("input").focus()
    @$("input").on
      click: => @fieldFocusIn(false)
      focus: => @fieldFocusIn(true)
      blur: => @fieldFocusOut()
    @get("logic").setOptions()
    #@setTempSpaceAsValue()

  setTempSpaceAsValue: (->
    Ember.run.next(=>
      if @get("value") == " "
        return
      val = @get("value")
      #unless @get("isDestroyed")
      unless Ember.typeOf(@get("value") == "undefined") or @get("value" == null)
        @set 'value', " "
        Ember.run.next =>
          unless Ember.isEmpty @get("value")
            @set 'value', val
    )
  ).observes("options")

  willDestroyElement: ->
    @set("logic.cachedOptions", null)
    @$("input").off()
    #@set("isDestroyed", true)

  keyDown: (e) ->
    switch e.keyCode
      when 38 #                    up arrow
        e.preventDefault()
        e.stopPropagation()
        @moveSelectionUp()
      when 40 #                    down arrow
        e.stopPropagation()
        e.preventDefault()
        @moveSelectionDown()
      when 13 #                    return
        clearTimeout(@get('typingTimer'))
        @set "logic.filter", @get "value"
        Ember.run.next =>
          @selectAndFire()

  replaceSlashWithDash: ->
    domObj = @$().find("input")
    jsDomObj = domObj.get(0)
    start =  jsDomObj.selectionStart
    end = jsDomObj.selectionEnd
    val = domObj.val()
    newVal = [val.slice(0, start), "-", val.slice(end)].join("")
    domObj.val(newVal)
    jsDomObj.setSelectionRange(start + 1, start + 1)


  keyUp: (e) ->
    switch e.keyCode
      when 27 # escape
        @showOptions false
        @$("input").blur()
      when 38, 40
        e.stopPropagation()
        e.preventDefault()
      else
        @showOptions true
    

  showOptions: (flag = true) ->
    try
      list = @$(".combo-list")
      if flag
        @set 'showing', true
        #@set "logic.filter", @get "value"
        list.width @$("input").innerWidth()
        list.removeClass "hide"
      else
        @set 'showing', false
        list.addClass "hide"

  actions:
    clickOption: (opt) ->
      @selectAndFire()

    selectOption: (opt) ->
      @logic.set "selectedOption", opt

    disclose: ->
      @$("input").focus()

LabCompass.inject "component:combo-box", "logic", "combo-box:logic"
