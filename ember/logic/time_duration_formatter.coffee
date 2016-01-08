LabCompass.TimeDurationFormatter = Ember.Object.extend
  format: (answer) ->
    duration = LabCompass.hoursMinutesSecondsFromTotalSeconds answer.get('answer')
    if duration.hours != "" && duration.minutes != "" && duration.seconds != ""
      "#{duration.hours}:#{duration.minutes}:#{duration.seconds}"

LabCompass.hoursMinutesSecondsFromTotalSeconds = (totalSeconds) ->
  if Ember.isEmpty(totalSeconds) || totalSeconds == "\u200d"
    hours: ""
    minutes: ""
    seconds: ""
  else
    totalSeconds = parseInt totalSeconds
    if !(totalSeconds >=0)
      totalSeconds = 0

    hours: Math.floor(totalSeconds / 3600)
    minutes: Math.floor((totalSeconds % 3600) / 60)
    seconds: (totalSeconds % 3600) % 60

LabCompass.totalSecondsFromHoursMinutesSeconds = (hours, minutes, seconds) ->
  if Ember.isEmpty(hours) && Ember.isEmpty(minutes) && Ember.isEmpty(seconds)
    ""
  else
    hours = parseInt(hours) || 0
    minutes = parseInt(minutes) || 0
    seconds = parseInt(seconds) || 0
    (hours * 3600) + (minutes * 60) + seconds

