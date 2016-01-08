#date-field
#gives mm/dd/yyyy style, date input, with an openable gui calender
LabCompass.DateFieldComponent = Ember.Component.extend
  _picker: null

  onMobile: Ember.computed(->
    try 
      document.createEvent("TouchEvent")
      return true
    catch error
      return false
  )
  mobileNot: Ember.computed.not("onMobile")

  # Ember doesn't bind readonly by default, so we need to add it here.
  attributeBindings: ['type', 'value', 'size', 'pattern', 'name', 'readonly']

  classNames: ["date"]

  didInsertElement: ->
    @_super(arguments...)
    currentYear = (new Date()).getFullYear()
    formElement = @$(".date-entry")[0]

    calendarButton = @$(".open-calendar")[0]
    picker = new Pikaday
      defaultDate: 'Invalid date'
      setDefaultDate: false
      field: formElement
      trigger: calendarButton
      format: 'MM/DD/YYYY'
      yearRange: [1900,currentYear+10]

    @set("_picker", picker)

  willDestroyElement: ->
    picker = @get("_picker")
    picker.destroy() if picker
