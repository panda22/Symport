LabCompass.ProjectController = Ember.ObjectController.extend

  breadCrumb: (->
    "#{@get('name')}"
  ).property("name")

  needs: 'application'
  compatibilityIssues: Ember.computed.alias 'controllers.application.compatibilityIssues'
  condensed_sidebar: Ember.computed.alias 'controllers.application.condensed_sidebar'

  init: ->
    @_super()
    @set "condensed_sidebar", false

  actions:
    collapseSidebar: ->
      left_side = document.getElementById("sidebar-id")
      right_side = document.getElementById("page-content")
      title_area = document.getElementById("titleArea")
      
      pushed = " "
      
      pushed = "pushed-down" if @get('compatibilityIssues') 

      if ! @get "condensed_sidebar"
        @set "condensed_sidebar", true
        left_side.setAttribute("class", "left-column condensed-sidebar-left ")	  
        right_side.setAttribute("class", "right-column condensed-sidebar-right")
        title_area.setAttribute("class", "title-area condensed-sidebar")
        $("#barText").addClass("condensed-sidebar")
      else
        @set "condensed_sidebar", false
        left_side.setAttribute("class", "left-column full-sidebar-left ") 
        right_side.setAttribute("class", "right-column full-sidebar-right")
        title_area.setAttribute("class", "title-area")
        $("#barText").removeClass("condensed-sidebar")

      pageTabs = $(".tabs")
      if pageTabs.length > 0
        if $(".breadcrumbs").height() > 18
          $(".tabs").css("margin-top", "1px")
        else
          $(".tabs").css("margin-top", "19px")

    colorForms: ->
      $('li[tooltip="Forms"]').css("color","#82bbe6")
      $('li[tooltip="Team"]').css("color","#cccccc")
      $('li[tooltip="Query"]').css("color","#cccccc")
      $('li[tooltip="Data"]').css("color","#cccccc")

    colorTeam: ->
      $('li[tooltip="Forms"]').css("color","#cccccc")
      $('li[tooltip="Team"]').css("color","#82bbe6")
      $('li[tooltip="Query"]').css("color","#cccccc")
      $('li[tooltip="Data"]').css("color","#cccccc")

    colorQuery: ->
      $('li[tooltip="Forms"]').css("color","#cccccc")
      $('li[tooltip="Team"]').css("color","#cccccc")
      $('li[tooltip="Query"]').css("color","#82bbe6")
      $('li[tooltip="Data"]').css("color","#cccccc")

    colorData: ->
      $('li[tooltip="Forms"]').css("color","#cccccc")
      $('li[tooltip="Team"]').css("color","#cccccc")
      $('li[tooltip="Query"]').css("color","#cccccc")
      $('li[tooltip="Data"]').css("color","#82bbe6")

