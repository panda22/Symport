#bread-crumbs
#used in a header file. Pulls page info from route and controller to draw linkabled breadcrumbs
LabCompass.BreadCrumbsComponent = Ember.Component.extend

  router: null
  applicationController: null

  handlerInfos: (->
    handlerInfos = @get("router").router.currentHandlerInfos
  ).property "applicationController.currentPath"

  pathNames: (->
    @get("handlerInfos").map (handlerInfo) ->
      handlerInfo.name
  ).property "handlerInfos.[]"

  controllers: (->
    @get("handlerInfos").map (handlerInfo) ->
      handlerInfo.handler.controller
  ).property "handlerInfos.[]"

  breadCrumbs: (->
    controllers = @get "controllers"
    defaultPaths = @get "pathNames"

    breadCrumbs = []

    controllers.forEach (controller, index) ->
      crumbName = controller.get "breadCrumb"
      if !Ember.isEmpty crumbName
        defaultPath = defaultPaths[index]
        specifiedPath = controller.get "breadCrumbPath"
        breadCrumbs.addObject
          name: crumbName
          shortName: if crumbName.length > 27 then crumbName.substring(0,27) + "..." else crumbName
          projectShortName: if crumbName.length > 42 then crumbName.substring(0,42) + "..." else crumbName 
          formShortName: if crumbName.length > 39 then crumbName.substring(0,39) + "..." else crumbName
          path: specifiedPath || defaultPath
          linkable: (specifiedPath != false)
          isCurrent: false

    deepestCrumb = breadCrumbs.get "lastObject"
    if deepestCrumb
      deepestCrumb.isCurrent = true

    breadCrumbs
  ).property "controllers.@each.breadCrumb", "controllers.@each.breadCrumbPath", "pathNames.[]"

Ember.onLoad "Ember.Application", (App) ->
  App.initializer
    name: "bread-crumb-init"
    initialize: (container, app) ->
      app.inject "component:bread-crumbs", "router", "router:main"
      app.inject "component:bread-crumbs", "applicationController", "controller:application"