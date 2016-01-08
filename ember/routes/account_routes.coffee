LabCompass.AccountDemoRoute = Ember.Route.extend
  model: (params)->
    if !Ember.isEmpty params.queryParams.name && !Ember.isEmpty params.queryParams.pwd
      name: params.queryParams.name
      pwd: params.queryParams.pwd

  setupController: (controller, model) ->
    try
      controller.setProperties
        email: model.name
        password: model.pwd
        error: false
        wantsEnter: true
    catch    
      controller.setProperties
        email: "guest@mntnlabs.com"
        password: "Symp0rt15"
        error: false
        wantsEnter: false

LabCompass.AccountSignInRoute = Ember.Route.extend
  setupController: (controller) ->
    controller.setProperties
      email: ""
      password: ""
      error: false

  actions:
    didTransition: ->
      @_super()
      Ember.run.next (=>
        @set "controller.condensed_sidebar", false
        $("#barText").removeClass("condensed-sidebar")
        $('.top-bar').css("z-index", 0)
        $('.my-projects-header-box').css("box-shadow", "none")
        $("#titleArea").css("box-shadow", "none")
        $("#barText").text("")
      )

LabCompass.AccountSignUpRoute = Ember.Route.extend

  model: ->
    @storage.createModel "user"

  setupController: (controller, model) ->
    @controller.setProperties
      model: model
      error: false

  actions:
    didTransition: ->
      @_super()
      Ember.run.next =>
        @set "controller.condensed_sidebar", false
        $("#barText").removeClass("condensed-sidebar")
        $('.top-bar').css("z-index", 0)
        $('.my-projects-header-box').css("box-shadow", "none")
        $("#titleArea").css("box-shadow", "none")
        $("#barText").text("")
        $(".top-bar").css("position","relative")
        try
          @controller.set 'c_id', grecaptcha.render("captcha", {'sitekey' : '6Lc7hQwTAAAAAI3JvTZjA0TehtLdPIK0PNf_1Siy'})
        catch
          Ember.run.later =>
            @controller.set 'c_id', grecaptcha.render("captcha", {'sitekey' : '6Lc7hQwTAAAAAI3JvTZjA0TehtLdPIK0PNf_1Siy'})
          , 500
LabCompass.AccountSignOutRoute = Ember.Route.extend

  beforeModel: (transition) ->

    #transition.abort()
    @storage.deauthorize()
    @session.reset()
    Ember.run.next(=>
      $(".top-bar").css("position", "relative")
      $(".top-bar").css("z-index", 10)
      $(".top-bar").css("box-shadow", "none")
      $("#titleArea").css("box-shadow", "none")
      $("#barText").text("")
      if $("#titleArea").hasClass("condensed-sidebar")
        $("#titleArea").removeClass("condensed-sidebar")
    )
    @transitionTo "account.sign-in"
    # TODO: tell the API to delete the token

LabCompass.AccountProfileRoute = LabCompass.ProtectedRoute.extend

  model: ->
    @storage.loadUser()

  actions:
    didTransition: ->
      @_super()
      Ember.run.next( =>
        $(".top-bar").css("position","relative")
        $(".top-bar").css("z-index", 10)
        $(".top-bar").css("box-shadow", "none")
        $("#titleArea").css("box-shadow", "none")
        $("#barText").text("")
        if $("#titleArea").hasClass("condensed-sidebar")
          $("#titleArea").removeClass("condensed-sidebar")
          @set "controller.condensed_sidebar", false
          $("#barText").removeClass("condensed-sidebar")
      )

LabCompass.AccountForgotPasswordRoute = Ember.Route.extend

  actions:
    willTransition: ->
      @_super()
      @get("controller").setProperties
        isError: false
        isSuccess: false

LabCompass.AccountResetPasswordRoute = Ember.Route.extend

  setupController: (controller) ->
    context = @get("context")
    @storage.verifyPasswordReset(context.uid, context.rid)
    .then (cur_user) =>
      if cur_user
        @controller.setProperties
          rid: context.rid
          uid: context.uid
          isError: false
          errorMessage: ""
          user: cur_user
      else
        @controller.setProperties
          isError: true
          errorMessage: "This password reset request has timed out. Please issue another request"



LabCompass.AccountRevalidateSessionRoute = Ember.Route.extend
  
  actions:
    didTransition: ->
      @_super()
      Ember.run.next( =>
        $(".top-bar").css("position","relative")
        $(".top-bar").css("z-index", 10)
        $(".top-bar").css("box-shadow", "none")
        $("#titleArea").css("box-shadow", "none")
        $("#barText").text("")
        if $("#titleArea").hasClass("condensed-sidebar")
          $("#titleArea").removeClass("condensed-sidebar")
          @set "controller.condensed_sidebar", false
          $("#barText").removeClass("condensed-sidebar")
        @session.stopTitle()
      )
      $(window).scrollTop(0)


LabCompass.AccountUserInviteRoute = Ember.Route.extend
  queryParams: ["uid, iid"]

  model: (params) ->
    @storage.userInviteSignIn(params.uid, params.iid).then (result) =>
      result
    , (result) ->
      result

