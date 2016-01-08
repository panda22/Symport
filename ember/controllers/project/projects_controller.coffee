LabCompass.ProjectsController = Ember.ArrayController.extend

  breadCrumb: "My Projects"

  init: ->
    if document.URL.indexOf("umich.symportresearch") != -1
      u = @get('session.user')
      heap.identify({handle: u.get('email'), name: (u.get('firstName')+" "+u.get('lastName'))})
