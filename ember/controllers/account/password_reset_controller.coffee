LabCompass.AccountResetPasswordController = Ember.Controller.extend
	uid: null
	rid: null

	isError: null
	errorMessage: ""
	user: null
	errorObj: {}

	password: null

	isSubmissionError: false
	submissionErrorMessage: ""
	isSuccessful: false

	actions:
		send: ->
			@set("isCalculating", true)
			@storage.verifyPasswordReset(@uid, @rid)
			.then (verifiedUser) =>
				if verifiedUser == null
					@set("isError", true)
					@set("errorMessage", "This password reset request has timed out. Please issue another request")
				else
					@storage.updatePassword(@get("user"), @rid, @uid)
					.then (result) =>
						if result == true
							@set("isSuccessful", true)
						else
							@set("isSubmissionError", true)
					, (errorInfo) =>
						console.error errorInfo
						@set("errorObj", errorInfo)
						@set("isSubmissionError", true)
		
		backToForgotPassword: ->
			@transitionToRoute "account.forgot-password"

		toLoginPage: ->
			@transitionToRoute "account.sign-in"