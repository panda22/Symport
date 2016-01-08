LabCompass.SecondaryIdDetailsController = Ember.ObjectController.extend LabCompass.WithProject,
	editModel: (->
		@get('model').copy()
	).property 'model'

	isResponseRename: false

	initResponseRename: (->
		@set("isResponseRename", false)
	).observes("model")

	newSecondaryIdNames: ""

	resetSecondaryIdNames: (->
		@set("newSecondaryIdNames", "")
	).observes("model")

	resetFormSecondaryIdName: (->
		if @get("editModel.isManyToOne")
			if @get("model.secondaryId") == "" or @get("model.secondaryId") == null
				@set("editModel.secondaryId", "Secondary ID")
			else
				@set("editModel.secondaryId", @get("model.secondaryId"))
		else
			@set("editModel.secondaryId", null)
	).observes("editModel.isManyToOne")

	actions:
		create: ->
			structure = @get("editModel")
			isManyToOneChange = (@get("editModel.isManyToOne") != @get("model.isManyToOne"))
			@storage.saveFormStructure(@get("project"), structure)
			.then (result) =>
				@set("isResponseRename", false)
				if @get("model.fromFormData")
					@send("updateSecondaryID", result)
				@send "closeDialog"
			, (errorStructure) =>
				if errorStructure.get("errors.content.isManyToOne").length and @get("editModel.isManyToOne") and isManyToOneChange
					errorStructure.set("errors.content.isManyToOne", [])
					#if @get("editModel.isManyToOne")
						#@storage.setResponseSecondaryIds(@get("editModel"), "1")
						#.then =>
						#	@set("isResponseRename", true)
					if @get("model.fromFormData")
						@send("updateSecondaryID", @get("editModel"))
					@set("isResponseRename", true)
					# TODO: catch error for has responses and open renamesecondaryids dialog

		renameResponses: ->
			@storage.setResponseSecondaryIds(@get("editModel"), @get("newSecondaryIdNames"))
			.then =>
				@set("isResponseRename", false)
				if @get("model.fromFormData")
					@send("updateSecondaryIdNames", @get("newSecondaryIdNames"))
				@send "closeDialog"
