LabCompass.QuestionSearchBarComponent = Ember.Component.extend
  
  isBuildContext: false
  setPlaceholder: false

  didInsertElement: ->
    if @isBuildContext
      $(window).on("resize", @resizeBarForBuilder)
      Ember.run.next(=>
        @resizeBarForBuilder()
      )
    else
      $(window).on("resize", @resizeBarForResponse)
      Ember.run.next(=>
        @resizeBarForResponse()
      )

    if @setPlaceholder
      $($(".drop-down-input")[0]).attr("placeholder", "Type to search for a question or variable name")
    

  willDestroyElement: ->
    if @isBuildContext
      $(window).off("resize", @resizeBarForBuilder)
    else
      $(window).off("resize", @resizeBarForResponse)


  resizeBarForBuilder: ->
    container = $(".question-search-row")
    textWidth = container.find(".main-info").width()
    container.find(".search-bar").width(container.width() - textWidth - 45)

  resizeBarForResponse: ->
    container = $(".question-search-row")
    textWidth = container.find(".main-info").width()
    container.find(".search-bar").width(container.width() - textWidth - 25)