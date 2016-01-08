#password-strength-indicator
#used to give front end validation for password strength and matching
#password: set to controller value that password is bound to
#confirm: set to controller value that password confirmation is bound to
LabCompass.PasswordStrengthIndicatorComponent = Ember.Component.extend

	password: null
	confirm: null

	updater: (-> 
		pass = @get('password')
		lowcase = false
		upcase = false
		number = false
		i = 0
		for i in [0..(pass.length-1)]
			char = pass.charAt(i)
			if char <= '9' && char >= '0'
				number = true
			if char <= 'z' && char >= 'a'
				lowcase = true
			if char <= 'Z' && char >= 'A'
				upcase = true

		@set 'length', i >=8
		@set 'notLength', !@get 'length'
		@set 'lowcase', lowcase
		@set 'notLowcase', !@get 'lowcase'
		@set 'upcase', upcase
		@set 'notUpcase', !@get 'upcase'
		@set 'number', number
		@set 'notNumber', !@get 'number'

	).observes 'password'

	sameCheck: (->
		if @hasBeenEntered()
			p1 = @get 'password'
			p2 = @get 'confirm'
			t = (p1 == p2 && p1 != "") 
			@set 'match', t
			@set 'notMatch', !t
	).observes 'password', 'confirm'

	hasBeenEntered: ->
		p1 = @get 'password'
		p2 = @get 'confirm'
		if ((p1 == "" or !p1) and (p2 == "" or !p2))
			@set 'length', false
			@set 'notLength', false
			@set 'lowcase', false
			@set 'notLowcase', false
			@set 'upcase', false
			@set 'notUpcase', false
			@set 'number', false
			@set 'notNumber', false
			@set 'match', false
			@set 'notMatch', false
			return false
		return true

	length: false
	notLength: false
	lowcase: false
	notLowcase: false
	upcase: false
	notUpcase: false
	number: false
	notNumber: false
	match: false
	notMatch: false