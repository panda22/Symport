#******************************************************

# usage notes:

# purpose:
# 	creates a drop-down that can have a property bound to it

# params:
# 	placeholder: default string in input. attached property will not have this value.
# 		your must also give this element class="placeholder" for this to take effect
# 	isEditable: if set to true, allows user to type in input and will make Suggestions
# 		based on partial string matching from what the user has typed
# 	val: controller or model property bound to input value
# 	inputOptions: array of strings that correspond to options for this element

# other notes:
# 	this component no longer uses mutation observers because they were not working
#	 	with Ember observers

#******************************************************

LabCompass.DropDownComponent = Ember.Component.extend
	listenForValues: false
	staySmall: false
	isEditable: null
	val: null
	options: Ember.A([])
	inputOptions: Ember.A([]) #this must be initialized when object is created in view
	inputOptionValue: null
	highlightedVal: ""
	placeholder: "" #must have class="placeholder" to set this
	isDisabled: Ember.computed(->
		if @get("disabled") != null and @get("disabled") == true
			return true
		return false
	)
	isBlockedFocus: Ember.computed(->
		if @get("stickyFocus")
			return true
		return false
	)

	didInsertElement: ->
		@setupOptions()
		@setBindingEvents()
		if @get("val") != null and @get("val") != ""
			@$().find("input").val(@get("val"))
		if @get("staySmall") == true
			@setStaySmall()

	setupOptions: ->
		comp = @
		if @get("highlightedVal")
			@set("highlightedVal", "")
		@set("options", Ember.A([]))
		input = @$().find(".drop-down-input")
		if @$().hasClass("placeholder")
			input.val(@get("placeholder"))
		#else
		#	input.val("")
		optionContainer = @$().find(".option-container")
		if @isEditable == false or @get("isDisabled")
			input.attr("readonly", true)
		if @get("isDisabled")
			@$().parent().children(".option").each(->
				$(this).addClass("hide")
			)
		else
			options = @get("options")
			# contruct options array from .option element
			@$().parent().children(".option").each(->
				#if comp.get("MutationObserver") and comp.get("listenForValues")
				#	comp.get("MutationObserver").observe($(this)[0], comp.get("observerConfig"))
				unless $(this).hasClass("no-option")
					text = $(this).text()
					options.pushObject(text)
					$(this).addClass("hide")
			)
			#construct options array from inputOptions array
			for option in @get("inputOptions")
				newOption = ""
				if @inputOptionValue != null
					if @listenForValues
						option.removeObserver("value", @, @setupOptions)
						option.addObserver("value", @, @setupOptions)
					tempOpt = null
					try
						tempOpt = option[@inputOptionValue] || option.get(@inputOptionValue)
					unless Ember.isEmpty(tempOpt)
						newOption = tempOpt
				else
					newOption = option
				options.pushObject(newOption)
			@constructOptions()

	isMouseMoved: true

	setupEditable: (->
		input = @$().find(".drop-down-input")
		if @get("isEditable") == false or @get("isDisabled")
			input.attr("readonly", true)
		else
			input.attr("readonly", false)
	).observes("isEditable", "isDisabled")

	listenForDisabled: (->
		disabled = @get("disabled")
		@set("isDisabled", disabled)
		if disabled == false
			@setupOptions()
			if @get("isEditable")
				@$().find("input").attr("readonly", false)
	).observes("disabled")

	listenForInputOptions: (->
		@setupOptions()
	).observes("inputOptions", "inputOptions.length", "inputOptions[].value")
	
	setStaySmall: ->
		@$().find(@$().find(".drop-down-wrapper")).css("width", "auto")
		@$().find(@$().find(".drop-down-wrapper")).css("min-width", "150px")
		@$().find(@$().find("input.drop-down-input")).css("width", "auto")
		@$().find(@$().find("input.drop-down-input")).css("min-width", "150px")
		@$().find(@$().find("input.drop-down-input")).css("padding-right", "10px")
		@$().find(@$().find(".option-container")).css("width", "auto")
		@$().find(@$().find(".option-container")).css("min-width", "150px")
		@$().find(@$().find(".drop-down-wrapper .option-container .option")).css("width", "auto")
		@$().find(@$().find(".drop-down-wrapper .option-container .option")).css("min-width", "150px")
		@$().find(@$().find(".drop-down-wrapper .option-container .option")).css("display", "list-item")
		@$().find(@$().find(".drop-down-wrapper .option-container .option")).css("padding-right", "10px")
		@$().find(@$().find("input.drop-down-input")).css("width", @$().find(@$().find("input.drop-down-input")).parent().find(".option-container").css("width"))

	setBindingEvents: ->
		input = @$().find(".drop-down-input")
		optionContainer = @$().find(".option-container")
		parentDiv = @$()
		comp = @

		optionContainer.mousemove(->
			comp.set("isMouseMoved", true)
		)

		#set observer for dom changes for .options added or taken away
		#observer = new MutationObserver((mutations) ->
		#  Ember.run.next(->
		#  	if comp and comp.$()
		#	  	parent = comp.$().parent()
		#	  	comp.set("options", Ember.A([]))
		#	  	comp.setupOptions()
		#  )
		#)

		#observer.observe((@$().parent())[0], @get("observerConfig"))
		#if @get("listenForValues")
		#	@$().parent().children(".option").each(->
		#		observer.observe($(this)[0], comp.get("observerConfig"))
		#	)
		#@set("MutationObserver", observer)

		placeholder = @get("placeholder")
		@$().focusin(->
			comp.toggleOptionContainer(true)
		)



		# new value entered in input by method other than typing
		input.bind("paste", ->
			#comp.checkEnteredValue()
			comp.set("val", $(this).val())
			if comp.get("isEditable") == false
				return
			comp.constructOptions($(this).val())
			comp.toggleOptionContainer(true)
			comp.handleClickForTouchEvent(comp)
		)

		input.bind("keydown", (e) ->
			if (e.keyCode == 27)
				return
			if e.keyCode == 9
				comp.handleFocusOut()
				return
			if comp.arrowKeyHighlight(e.keyCode)
				e.stopPropagation()
				e.preventDefault()
			else
				if comp.get("isEditable") == false
					comp.findOptionOnKeyPress(String.fromCharCode(e.keyCode))
					return
				comp.toggleOptionContainer(true)
		)

		input.bind("keyup", (e) ->
			if comp.get("isEditable") == true
				if e.keyCode >= 37 and e.keyCode <= 40 # any arrow key
					return
				if (e.keyCode == 27) || (e.keyCode == 13) #tab or escape or enter/return
					comp.handleFocusOut()
					return
				comp.set("val", $(this).val())
				comp.constructOptions($(this).val())
		)

	handleClickForTouchEvent: (comp) ->
		if @get("isBlockedFocus") == false
			$(document).one("touchend", (e) ->
				comp.handleClick(e, comp)
			)
		$(document).one("mouseup", (e) ->
			comp.handleClick(e, comp)
		)

	findOptionOnKeyPress: (char) ->
		comp = @
		optionContainer = @$().find(".option-container")
		optionContainer.find(".option").each(->
			if $(this).text().charAt(0).toUpperCase() == char.toUpperCase()
				optionContainer.find(".highlighted").removeClass("highlighted")
				$(this).addClass("highlighted")
				comp.scrollToOption($(this))
				return
		)

	toggleOptionContainer: (show=true) ->
		if @get("isDisabled")
			return
		comp = @
		optionContainer = @$().find(".option-container")
		if show and optionContainer.hasClass("hide")
			optionContainer.removeClass("hide")
			#	$(document).bind("keydown", @removeArrowScroll)
			comp.handleClickForTouchEvent(comp)
		else if show == false and !optionContainer.hasClass("hide")
			optionContainer.addClass("hide")
			#	$(document).unbind("keydown", @removeArrowScroll)

	removeArrowScroll: (e) ->
		if e.keycode == 38 or e.keycode = 40
			e.preventDefault()

	optionClicked: (comp, input, optionContainer, target) ->
		text = target.text()
		unless text == "No Suggestions Found"
			input.val(target.text())
			comp.set("val", target.text())
		target.parent().addClass("hide")
		comp.set("highlightedVal", "")
		optionContainer.find(".highlighted").removeClass("highlighted")
		

	# if clicked outside of dom object hide options
	# if option clicked handle with option clicked
	# else reset listener
	handleClick: (e, comp) ->
		parentDiv = comp.$()
		optionContainer = comp.$().find(".option-container")
		if !parentDiv.is(e.target) && parentDiv.has(e.target).length == 0
			@handleFocusOut()
		else
			if comp.get("isEditable") and $(e.target).hasClass("drop-down-input") and $(e.target).val() == comp.get("placeholder")
				$(e.target).val("")
			if comp.get("isEditable") and $(e.target).hasClass("drop-down-input")
				comp.constructOptions()
			if $(e.target).hasClass("option")
				comp.optionClicked(comp, parentDiv.find("input"), optionContainer, $(e.target))
			comp.handleClickForTouchEvent(comp)

	handleFocusOut: ->
		optionContainer = @$().find(".option-container")
		input = @$().find(".drop-down-input")
		@toggleOptionContainer(false)
		#input.trigger("blur")
		@set("highlightedVal", "")
		optionContainer.find(".highlighted").removeClass("highlighted")
		


		#if @get("isEditable")
			#newVal = ""
			#curVal = input.val()
			#@set("val", curVal)
			#for option in @get("options")
			#	if option == curVal
			#		newVal = option
			#		break
			#input.val(newVal)
			#@set("val", newVal)

	# returns true if arrowkey or enter was typed and manipulated else false
	arrowKeyHighlight: (keyCode) ->
		optionContainer = @$().find(".option-container")
		comp = @
		if keyCode == 40 #downarrow
			comp.set("isMouseMoved", false)
			#$(".highlighted").removeClass("highlighted")
			if optionContainer.find(".highlighted").length == 0
				optionContainer.find(".option").first().addClass("highlighted")
				@set("highlightedVal", comp.$().find(".highlighted").text())
				optionContainer.scrollTop(optionContainer.find(".highlighted").position().top)
			else
				isFound = false
				optionContainer.find(".option").each(->
					if isFound
						$(this).addClass("highlighted")
						comp.set("highlightedVal", $(this).text())
						comp.scrollToOption($(this))
						return false
					if $(this).hasClass("highlighted")
						$(this).removeClass("highlighted")
						isFound = true
				)
			return true
		else if keyCode == 38 #uparrow
			comp.set("isMouseMoved", false)
			#$(".highlighted").removeClass("highlighted")
			if optionContainer.find(".highlighted").length == 0
				lastOption = optionContainer.find(".option").last()
				lastOption.addClass("highlighted")
				@set("highlightedVal", comp.$().find(".highlighted").text())
				optionContainer.scrollTop(lastOption.position().top)
			else
				prevElem = null
				optionContainer.find(".option").each(->
					if $(this).hasClass("highlighted")
						$(this).removeClass("highlighted")
						if prevElem != null
							prevElem.addClass("highlighted")
							comp.set("highlightedVal", prevElem.text())
							comp.scrollToOption(prevElem)
					prevElem = $(this)
				)
			return true
		else if keyCode == 13 #return/enter
			highlighted = optionContainer.find(".highlighted")
			if @get("highlightedVal") != ""
				input = @$().find(".drop-down-input")
				if !@get("isEditable") or @get("highlightedVal").indexOf(input.val()) != -1
					@set("val", @get("highlightedVal"))
					input.val(@get("highlightedVal"))
					@set("highlightedVal", "")
			optionContainer.find(".highlighted").removeClass("highlighted")
			@toggleOptionContainer(false)
			return true
		else
			return false

	scrollToOption: (optionObj) ->
		optionHeight = parseInt(optionObj.css("height"))
		optionContainer = @$().find(".option-container")
		if optionObj.position().top < 0
			optionContainer.scrollTop(optionContainer.scrollTop() + optionObj.position().top)
		else if optionObj.position().top + optionHeight > optionContainer.height()
			optionContainer.scrollTop(optionContainer.scrollTop() + optionObj.position().top + optionHeight - optionContainer.height())


	checkEnteredValue: ->
		value = @$().find(".drop-down-input").val()
		for option in @get("options")
			if value == option
				@set("val", value)
				break

	constructOptions: (searchStr="") ->
		optionContainer = @$().find(".option-container")
		optionContainer.html("")
		comp = @
		isFirst = true
		for option, i in @get("options")
			if Ember.isEmpty(option)
				continue
			if option.toUpperCase().indexOf(searchStr.toUpperCase()) > -1
				if isFirst #highlight first matched option
					optionContainer.append("<div class='option highlighted'>" + option + "</div>")
					@set("highlightedVal", option)
					isFirst = false
				else
					optionContainer.append("<div class='option'>" + option + "</div>")
		if optionContainer.children().length == 0 and @get("isDisabled") == false
			optionContainer.append("<div class='option no-option'>No Suggestions Found</div>")
		maxHeight = parseInt(optionContainer.css("max-height"))
		regHeight = parseInt(optionContainer.css("height"))
		if regHeight < maxHeight
			optionContainer.css("overflow-y", "hidden")
		else
			optionContainer.css("overflow-y", "scroll")
		$(".option").hover(->
			if comp.get("isMouseMoved")
				$(".highlighted").removeClass("highlighted")
				$(this).addClass("highlighted")
		, ->
			$(this).removeClass("highlighted")
		)
		@$().find(".option-container").css("width", @$().find("input").css("width"))



	willDestroyElement: ->
		optionContainer = @$().find(".option-container")
		@set("options", Ember.A([]))
		#@set("val", null)
		@set("isEditable", null)
		optionContainer.html("")
		#@get("MutationObserver").disconnect()

	actions:
		setTestOption: ->
			val = @$().find(".drop-down-test input").val()
			@set("val", val)
			@$().find("input:eq(0)").val(val)
			#sendAction("testAction", @get("boundVal"), val)
