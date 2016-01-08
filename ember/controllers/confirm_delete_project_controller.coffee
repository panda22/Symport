LabCompass.ConfirmDeleteProjectController = Ember.ObjectController.extend
  input: ""
  
  canDelete: (->
  	@get('input') == "DELETE"
  ).property 'input'
  
  actions:
    confirm: ->
      @set 'error', false
      if @get('canDelete')
      	@set 'input', ""
      	@send 'deleteProject', @get('model')
      else
      	Ember.run.next => 
      	  @set 'error', true