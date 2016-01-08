#time-duration-field
#used by AnswerTypeSpecificUI for time duration type answers
LabCompass.TimeDurationFieldComponent = Ember.Component.extend

  disabled: false

  setValueObserver: Ember.observer((->
    totalSeconds = @hoursMinutesSecondsToDisplay(@get("hours"), @get("minutes"), @get("seconds"))
    unless Ember.isEmpty(totalSeconds) and !Ember.isEmpty(@get("value"))
      @set('value', totalSeconds)
  ), 'hours', 'minutes', 'seconds')

  didInsertElement: ->
    @_super(arguments...)
    for property, value of @displayToHoursMinutesSeconds(@get('value'))
      @set(property, value)

  hoursMinutesSecondsToDisplay: (hours, minutes, seconds) ->
    if Ember.isEmpty(hours) && Ember.isEmpty(minutes) && Ember.isEmpty(seconds)
      hours = ""
      minutes = ""
      seconds = ""
    else
      if Ember.isEmpty(hours)
        hours = "0"
      if Ember.isEmpty(minutes)
        minutes = "0" 
      if Ember.isEmpty(seconds)
        seconds = "0"

    t = "#{hours}:#{minutes}:#{seconds}"
    if t == "::"
      t = ""

    return t

  displayToHoursMinutesSeconds: (display) ->
    match = /^(\d+):(\d+):(\d+)$/.exec display

    if match
      hours: match[1]
      minutes: match[2]
      seconds: match[3]
    else
      hours: ""
      minutes: ""
      seconds: ""