#unused and likely deprecated
LabCompass.TimeField = Ember.TextField.extend
  type: 'time'
  valueBinding: 'timeValue'
  timeValue: ((key, value) ->
    if value
      @set 'time', new Time(value)
    else
      (@get 'time' || new Time()).toISOString().substring(0, 10)
  ).property('time')

