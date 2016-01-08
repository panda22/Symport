LabCompass.ApplicationController = Ember.Controller.extend
  compatibilityIssues: false
  condensed_sidebar: false

  mobileDevice: {
    Android: ->
      return navigator.userAgent.match(/Android/i) != null
    BlackBerry: ->
      return navigator.userAgent.match(/BlackBerry/i) != null
    iOS: ->
      return navigator.userAgent.match(/iPhone|iPad|iPod/i) != null
    Opera: ->
      return navigator.userAgent.match(/Opera Mini/i) != null
    Windows: ->
      return navigator.userAgent.match(/IEMobile/i) != null
  }

  isMobile: ->
    return (@mobileDevice.Android() || @mobileDevice.BlackBerry() || @mobileDevice.iOS() || @mobileDevice.Opera() || @mobileDevice.Windows())

  onMobile: Ember.computed(->
    try
      document.createEvent("TouchEvent")
      return true
    catch error
      return false
  )

  onboardingProgress: true

  init: ->
    @_super()
    try
      document.createEvent("TouchEvent")
      @set('compatibilityIssues', false)
    catch error
      unless !!(document.createElement('datalist') && window.HTMLDataListElement)
        @set('compatibilityIssues', true)

    $(document).mousemove (e)=>
      @refreshSession()

    $(document).keypress (e)=>
      @refreshSession()

    $(window).resize (e)=>
      @handleHeaderBox()
      @handleTabs()

    $(document).scroll (e)=>
      myCurrentPath = @get("currentPath")
      if myCurrentPath.substring(0,10) == "projects.i"
        #we are in the projects.index page
        @handleStickyIndex()
      else if myCurrentPath.substring(0,10) == "projects.p"
        #we are in everything else for projects
        @handleStickyProjects()

 
  rdyForRefresh: true
  refreshSession: (->
    if @get('rdyForRefresh') || @get("session.isDying")
      @set 'rdyForRefresh', false
      @storage.makeSessionValid()
      @session.stopTitle()
      window.setTimeout(=>
        @set 'rdyForRefresh', true
      ,2400000)
  ).on("init")

  handleStickyIndex: ->
    if $(document).scrollTop() > 0
      $('.top-bar').css("z-index", 10)
      $(".my-projects-header-box").css("box-shadow", "1px 5px 5px #cccccc")
      $("#titleArea").css("box-shadow", "-3px 5px 10px #cccccc")
    else
      $('.top-bar').css("z-index", 2)
      $('.my-projects-header-box').css("box-shadow", "none")
      $("#titleArea").css("box-shadow", "none")
      @handleHeaderBox()

  handleStickyProjects: ->
    if $(document).scrollTop() > 0
      $('.top-bar').css("z-index", 12)
      $(".top-bar").css("box-shadow", "0px 5px 10px #cccccc")
      $("#titleArea").css("box-shadow", "31px 22px 10px -26px #cccccc")
    else
      $('.top-bar').css("z-index", 1)
      $(".top-bar").css("box-shadow", "none")
      $("#titleArea").css("box-shadow", "-17px -22px 10px 21px #cccccc")
      @handleHeaderBox()

  handleHeaderBox: ->
    if $(document).scrollLeft() > 0
      $(".breadcrumbs").css("position", "static")
      if $(document).scrollLeft() > 46
        $(".header-box").css("position","relative")
        $(".header-box").css("z-index",-1)
      else
        $(".header-box").css("position","static")    
        $(".header-box").css("z-index","auto")        
    else
      $(".breadcrumbs").css("position", "relative")

  handleTabs: ->
    if $(".tabs").length
      if $(".breadcrumbs").height() > 18
        $(".tabs").css("margin-top", "1px")
      else
        $(".tabs").css("margin-top", "19px")

  actions:
    goToHelp: ->
      @send "openDialog", "support"

