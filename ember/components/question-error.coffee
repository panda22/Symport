#******************************************************

# usage notes:

# purpose:
# 	creates a page error message that will scroll to first question error on didInsertElement

# parameters:
# 	errorString: error message to be displayed
# 	questionsObject: question object with error
# 		see model form_question.coffee for more details

#******************************************************

LabCompass.QuestionErrorComponent = Ember.Component.extend
	questionString: null
	questionObject: null

	didInsertElement: ->
		errorDiv = @getFirstErrorMessage()
		focusDomObj = errorDiv.parent().parent().children("input, textarea, select")
		$(".error-notification").removeClass("hidden")
		if focusDomObj.length == 0
			focusDomObj = errorDiv
			offset = focusDomObj.offset().top - $("#question-builder-left-side").offset().top - $("#question-builder-left-side").height() * .8
			$("#question-builder-left-side").scrollTop(offset)
		else 
			focusDomObj.focus()
			focusDomObj[0].scrollIntoViewIfNeeded()

	getFirstErrorMessage: ->
		retValue = null
		$(".sub-error").each(->
			if retValue == null or retValue.offset().top > $(this).offset().top
				retValue = $(this)
		)
		return retValue

	willDestroyElement: ->
		if $(".sub-error").length == 1
			$(".error-notification").addClass("hidden")