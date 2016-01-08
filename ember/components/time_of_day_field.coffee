#time-of-day-field
#used by AnswerTypeSpecificUI for time of day type answers 
LabCompass.TimeOfDayFieldComponent = Ember.Component.extend

  disabled: false

  ampmList: ["AM", "PM", ""]
  setValueObserver: Ember.observer((->
    totalMinutes = @hoursMinutesAmpmToDisplay(@get("hours"), @get("minutes"), @get("ampmValue"))
    unless Ember.isEmpty(totalMinutes) and !Ember.isEmpty(@get("value"))
      @set('value', totalMinutes)
  ), 'hours', 'minutes', 'ampmValue')

  didInsertElement: ->
    @_super(arguments...)
    totalMinutes = @get('value')
    for property, value of @displayToHoursMinutesAmpm(totalMinutes)
      @set(property, value)

  hoursMinutesAmpmToDisplay: (hours, minutes, ampm) ->
    if Ember.isEmpty(hours) && Ember.isEmpty(minutes)
      ""
    else if Ember.isEmpty(hours) && !Ember.isEmpty(minutes)
      if !Ember.isEmpty(ampm)
        "00:#{minutes} #{ampm}"
      else
        "00:#{minutes}"
    else if !Ember.isEmpty(hours) && Ember.isEmpty(minutes)
      if !Ember.isEmpty(ampm)
        "#{hours}:00 #{ampm}"
      else
        "#{hours}:00"
    else
      if !Ember.isEmpty(ampm)
        "#{hours}:#{minutes} #{ampm}"
      else
        "#{hours}:#{minutes}"

  displayToHoursMinutesAmpm: (display) ->
    match = /^(\d+):(\d+) (AM|PM)$/.exec display

    if match
      hours: match[1]
      minutes: match[2]
      ampmValue: match[3]
    else
      match = /^(\d+):(\d+)/.exec display
      if match
        hours: match[1]
        minutes: match[2]
        ampmValue: ""
      else
        hours: ""
        minutes: ""
        ampmValue: "AM"
