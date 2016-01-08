LabCompass.Router.map ->

  @route "test"

  @route "grid-test"

  @resource "account", ->
    @route "sign-in"
    @route "demo"
    @route "sign-out"
    @route "sign-up"
    @route "timed-out"
    @route "profile"
    @route "forgot-password"
    @route "reset-password", path: "reset-password/:uid/:rid"
    @route "revalidate-session"
    @route "user-invite", path: "user-invite/:uid/:iid"

  @resource "projects", ->
    @route "overlays"
    @route "create"
    @resource "project", path: ":projectID", ->
      @route "form-data"
      @resource "view-and-query", ->
        @route "view"
        @route "saved-queries"
        @route "results"
        @route "query"
      @route "create-form-structure"
      @resource "team-members", ->
        @resource "team-member", path: ":teamMemberID", ->
          @route "edit"
      @resource "forms", ->
        @resource "form", path: ":formID", ->
          @route "build"
          @route "preview"
          @route "grid"
          @resource "responses", ->
            @resource "response", path: ":responseID", ->
              @route "edit"
              @route "view"
      @route "import"
      
