#checkbox that can have an action wired to its changing value
LabCompass.ActionableCheckbox = Ember.Checkbox.extend
  init: ->
    #@set("controller.isDomLoading", false)
    action = @get('action')
    if action
      @on('change', this, this.sendHookup)

  sendHookup: (ev) ->
    if @get("controller.isDomLoading") == true
      @$().prop('checked', @get("checked"))
      return
    else
      @set("controller.isDomLoading", true)
      action = @get('action')
      controller = @get('controller')
      controller.send(action,  @$().prop('checked'), if (@get('param')) then @get('param') else null)
      comp = @
      Ember.run.next(->
        window.setTimeout( ->
          comp.set("controller.isDomLoading", false)
        , 50)
      )

    #@sendAction(action, param)

  isDomLoading: false

  willDestroyElement: ->
    @off('change', @, @sendHookup);