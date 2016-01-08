LabCompass.User = LD.Model.extend

  email: LD.attr "string"
  firstName: LD.attr "string"
  lastName: LD.attr "string"
  phoneNumber: LD.attr "string"
  lastViewedProject: LD.attr "string"
  demoProgress: LD.attr "number"
  lastViewedPage: LD.attr "string"

  create: LD.attr "boolean"
  import: LD.attr "boolean"
  format: LD.attr "boolean"
  clean: LD.attr "boolean"
  invite: LD.attr "boolean"

  done: false
  remSteps: 5
  stepsRemain: false
  saveStartStuff: ->
    i = 0
    if @get('create')
      i = i + 1
    if @get('import')
      i = i + 1
    if @get('clean')
      i = i + 1
    if @get('format')
      i = i + 1
    if @get('invite')
      i = i + 1
    @set 'remSteps', i
    if i == 5
      @set 'done', true
    else
      @set 'done', false
    Ember.run.next ->
      $(document).foundation()
    Ember.run.later =>
      @set('stepsRemain', (i != 5))
      Ember.run.next =>
        $(document).foundation()
    , 3000
    @saveMyself()
  
  flashGettingStarted: ->
    if @get('waitOnce')
      @set 'waitOnce', false
    else
      Ember.run.next ->
        a = $("#getting-started")
        a.addClass('hover')
        Ember.run.later =>
          a.removeClass("hover")
        , 3000

  waitOnce: true

  callSaveStuff: (->
    Ember.run.once(this, 'saveStartStuff')
    Ember.run.once(this, 'flashGettingStarted')
  ).observes("create", "import", "clean", "format", "invite")

  saveMyself: ->
    @storage.saveUser(@).then (user)=>
      @storage.set('session.user', user)

  affiliation: LD.attr "string"
  fieldOfStudy: LD.attr "string"

  password: LD.attr "string"
  passwordConfirmation: LD.attr "string"

  currentPassword: LD.attr "string"
  captcha: LD.attr "string"