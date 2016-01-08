LabCompass.ProjectsOverlaysController = Ember.ObjectController.extend

  notFirstPage: (->
  	return (@get 'model.demoProgress') != 0
  ).property 'model.demoProgress'

  notLastPage: (->
  	return (@get 'model.demoProgress') <= 5
  ).property 'model.demoProgress'

  changeOverlay: (->
    unless @get 'dontChangeImage'
      try $('#image').attr('class', ('overlay' + @get('model.demoProgress')) )
  ).observes 'model.demoProgress'

  count: (->
    return (@get('demoProgress') + 1)
  ).property 'model.demoProgress'

  dontChangeImage: false

  actions:
    lastPage: ->
      num = @get 'model.demoProgress'
      @set 'model.demoProgress', (num - 1)
      @send 'save'
    nextPage: ->
      num = @get 'model.demoProgress'
      if num > 5
        @transitionToRoute "projects.index"
      else
        @set 'model.demoProgress', (num + 1)
        @send 'save'
    skip: ->
      @set 'dontChangeImage', true
      @set 'model.demoProgress', 6
      
      @storage.saveUser @get "model"
      .then (user) =>
        @session.set "user", user
        @transitionToRoute "projects.index"

    save: ->
      @storage.saveUser @get "model"
      .then (user) =>
        @session.set "user", user