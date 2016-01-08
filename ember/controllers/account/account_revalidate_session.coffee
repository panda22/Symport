LabCompass.AccountRevalidateSessionController = Ember.Controller.extend
	needs: 'application'
	condensed_sidebar: Ember.computed.alias 'controllers.application.condensed_sidebar'

	password: null
	isError: false
	errorMessage: ""
	numAttempts: 0

	handleError: ->
		@set("numAttempts", @get("numAttempts") + 1)
		if @get("numAttempts") >= 5
			@set("errorMessage", "You will be directed to the sign-in page due to 5 failed login attempts")
			window.setTimeout( =>
				@transitionToRoute("account.sign-in")
			, 1000)
		else
			@set("errorMessage", "Incorrect password, please try again")
		@set("isError", true)


	actions:
		signBackIn: ->
			email = @session.get("user.email")
			history = @session.history
			if history.length > 0
				prevPath = history[history.length - 1]
			else
				prevPath = "/projects"
			@storage.authorize(email, @password).then =>
				@set("password", "")
				@set("isError", false)
				@set("password", null)
				@set("numAttempts", 0)
				@session.set("history", history)
				try
					@transitionToRoute prevPath
				catch
					try
						@transitionToRoute "projects.index"
					catch
						@transitionToRoute "account.sign-in"	
			, (errorMessage) =>
				@set("password", "")
				@handleError()