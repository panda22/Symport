#deprecated, will not always work in popups. use the takeFocus mixin or probobly a LabCompass.'some type' that already exists and has the focus mixin
LabCompass.TextFieldAutoFocused = Ember.TextField.extend
	didInsertElement: ->
		@$().focus()