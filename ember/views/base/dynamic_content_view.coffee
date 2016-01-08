LabCompass.DynamicContentView = Ember.ContainerView.extend

  updateView: (->
    oldView = @[0]
    newView = @get 'dynamicView'
    if oldView != newView
      @set "[]", [newView]
      Ember.run.next ->
        oldView.destroy() if oldView
  ).observes("dynamicView").on("init")

