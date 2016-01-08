LabCompass.AccountForgotPasswordController = Ember.Controller.extend
	
	isError: false
	isNotError: Ember.computed.not("isError")
	isSuccess: false
	email: ""
	isGeneratingEmail: false

	actions:
		cancel: ->
			@transitionToRoute "account.sign-in"

		send: ->
			email = @get("email").trim()
			@set("isGeneratingEmail", true)
			@storage.forgotPassword(email)
			.then (result) =>
				if result.result == true
					@set("isSuccess", true)
					@set("isError", false)
					@set("isGeneratingEmail", false)
				else
					@set("isSuccess", false)
					@set("isError", true)
					@set("isGeneratingEmail", false)			
			, (error) =>
				@set("isSuccess", false)
				@set("isError", true)
				@set("isGeneratingEmail", false)
