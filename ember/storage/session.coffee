attr = (name, opts={}) ->
  opts = Ember.merge
    default: null
    class: null
  , opts

  ((k, v) ->
    if arguments.length > 1
      valueToSerialize = if opts.class
        v.serialize() if v
      else
        v
      sessionStorage[name] = JSON.stringify valueToSerialize
      v
    else
      try
        extractedValue = JSON.parse sessionStorage[name]
        if opts.class && extractedValue
          storage = @container.lookup "storage:main"
          storage.createModel opts.class, extractedValue
        else
          extractedValue
      catch error
        null

  ).property()

LabCompass.Session = Ember.Object.extend
  sessionToken: attr "sessionToken"
  isAuthenticated: attr "isAuthenticated", default: false
  user: attr "user", class: "user"
  history: Ember.A([])
  queryParamInfo: Ember.Object.create({
    queryParams: Ember.A([])
    queriedForms: {}
    queryConjunction: ""
    projectID: ""
  })


  beginSession: (sessionToken, user) ->
    Ember.run =>
      @setProperties
        sessionToken: sessionToken
        isAuthenticated: true
        user: user
        history: Ember.A()

  reset: (temporary=false) ->
    if temporary
      @setProperties
        sessionToken: null
        isAuthenticated: false
    else
      @setProperties
        sessionToken: null
        user: null
        isAuthenticated: false

  expireIfNecessary: ->
    if @get "isAuthenticated"
      @reset(true)
      route = @container.lookup("route:application")
      if route && route.get('currentDialog')
        route.send "closeDialog"
      @container.lookup("router:main").transitionTo "account.revalidate-session"

  isDying: false

  initTitleFlash: (->
    window.setTimeout(=>
      if @get("isDying") == true
        if document.title == "Symport"
          document.title = "Timeout Imminent"
        else
          document.title = "Symport"
      @initTitleFlash()
    , 2000)
  ).observes("isDying")

  dealWithTitle: ->
    @set("isDying", true)

  stopTitle: ->
    @set("isDying", false)
    document.title = "Symport"

  sessionChecker: (->
    interval = @get "sessionCheckInterval"
    clearInterval interval
    if @get "isAuthenticated"
      interval = setInterval =>
        @container.lookup("storage:main").checkSession()
        .then (response) =>
          if !response.active
            @expireIfNecessary()
          else
          if response.dying
            @dealWithTitle()
      ,2 * 10 * 6000 # 2 minutes
    @set "sessionCheckInterval", interval
  ).observes("isAuthenticated").on "init"

LabCompass.register "session:main", LabCompass.Session
LabCompass.inject "route", "session", "session:main"
LabCompass.inject "controller", "session", "session:main"
