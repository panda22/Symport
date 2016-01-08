LabCompass.RenameInstanceController = Ember.ObjectController.extend

	needs: ["response"]

	response: Ember.computed.alias("controllers.response")

	#NEEDED FOR SOME WEIRD REASON
	#MODEL.SECONDARYID IN EMBLEM WON'T WORK WITHOUT
	newSecondaryId: ""

	actions:
		saveResponse: ->
			if @get("model.secondaryID") == null or @get("model.id") == null
				return
			@storage.renameInstance(@get("model"), @get("newSecondaryId"))
			.then (result) =>
				@send("updateSecondaryId", result)
				@send "closeDialog"