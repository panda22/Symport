#becoming deprecated. use datatable paging from now on
LabCompass.PageNumbersComponent = Ember.Component.extend

  currentPage: null
  totalPages: null

  maxPagesToDisplay: 11 #should be odd

  pageItems: (->
    currentPage = Number @get "currentPage"
    totalPages = Number @get "totalPages"
    maxPages = Number @get "maxPagesToDisplay"
    # ensure that maxPages is odd
    maxPages += 1 - maxPages % 2

    pages = for pageNumber in [1..totalPages]
      ellipses: false
      page: pageNumber
      current: currentPage == pageNumber

    if pages.length > maxPages
      # determine position in truncated array (1 to max)
      positionOfCurrent = ((maxPages - 1) / 2) + 1
      # does the position need to be shifted left?
      if positionOfCurrent > currentPage
        positionOfCurrent = currentPage
      # does the position need to be shifted right?
      if (totalPages - currentPage) < (maxPages - positionOfCurrent)
        positionOfCurrent = maxPages - (totalPages - currentPage)

      # if distance from max is greater than delta of values, truncate
      if (totalPages - currentPage) > (maxPages - positionOfCurrent)
        maxDistance = maxPages - positionOfCurrent
        overspill = totalPages - currentPage - maxDistance
        toRemove = overspill + 1
        idx = totalPages - 1 - toRemove
        pages.replace idx, toRemove, [
          ellipses: true
        ]


      # if distance from 1 is greater than delta of values, truncate
      if currentPage > positionOfCurrent
        maxDistance = positionOfCurrent
        overspill = currentPage - positionOfCurrent
        toRemove = overspill + 1
        idx = 1
        pages.replace idx, toRemove, [
          ellipses: true
        ]

    pages
  ).property "currentPage", "totalPages", "maxPagesToDisplay"

  needsPages: (->
    Number(@get("totalPages")) > 1
  ).property "totalPages"

  canStepForward: (->
    page = Number @get "currentPage"
    totalPages = Number @get "totalPages"
    page < totalPages
  ).property "currentPage", "totalPages"

  canStepBackward: (->
    page = Number @get "currentPage"
    page > 1
  ).property "currentPage"

  actions:
    pageClicked: (number) ->
      @set "currentPage", number

    stepForward: ->
      @incrementProperty "currentPage"

    stepBackward: ->
      @decrementProperty "currentPage"
