LabCompass.ViewAndQuerySavedQueriesController = Ember.ArrayController.extend LabCompass.WithProject,
	breadCrumb: "Query"

	orderTypes: Ember.A([
		"Recently Edited First",
		"Recently Edited Last",
		"A-Z",
		"Z-A"
	])
	curOrderType: (->
		@orderTypes[0]
	).property "model"

	listenForOrderType: (->
		orderParam = @getOrderParamFromTypes(@curOrderType)
		@storage.getSavedQueries(@get("project.id"), orderParam)
		.then (result) =>
			@set("model", result)
	).observes("curOrderType")

	getOrderParamFromTypes: (type) ->
		if type == @orderTypes[0]
			return "editedDescending"
		else if type == @orderTypes[1]
			return "editedAscending"
		else if type == @orderTypes[2]
			return "a-z"
		else if type == @orderTypes[3]
			return "z-a"


	actions:
		buildQuery: ->
			@transitionToRoute("view-and-query.query")

		editQuery: (query) ->
			@transitionToRoute("view-and-query.query", {queryParams: {query: query}})

		runQuery: (query) ->
			@transitionToRoute("view-and-query.results", {queryParams: {query: query}})

		deleteQuery: (query) ->
			@send "openDialog", "confirm_delete_query", query, "viewAndQueryConfirmDeleteQuery"

		duplicateQuery: (query) ->
			newQuery = query.copy()
			newQuery.set("id", null)
			newQuery.set("name", "")
			@transitionToRoute("view-and-query.query", {queryParams: {query: newQuery}})

		editQueryPermissions: (query) ->
			query.set("isNameEdit", false)
			@send("openDialog", "edit_query_name_or_permissions", query, "viewAndQueryConfirmEditNameOrPermissions")

		renameQuery: (query) ->
			query.set("isNameEdit", true)
			@send("openDialog", "edit_query_name_or_permissions", query, "viewAndQueryConfirmEditNameOrPermissions")





