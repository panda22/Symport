LabCompass.FormController = Ember.Controller.extend

  breadCrumb: (->
    "Form Name - #{@get('model.name')}"
  ).property("model.name")

  #breadCrumb: "Form Name - #{@get('model.name')}"

  breadCrumbPath: false
