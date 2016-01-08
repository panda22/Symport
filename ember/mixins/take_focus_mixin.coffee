#Element will take focus on didInsertElement or dialog reveal
LabCompass.TakeFocusMixin = Ember.Mixin.create

  takeFocus: false

  becomeFocused: (->
    if @get "takeFocus"
      @$().focus()
      $(document).on 'opened', '[data-reveal]', =>
        @$().focus()
  ).on('didInsertElement')

  releaseHandler: (->
  	if @get "takeFocus"
  	  $(document).off 'opened', '[data-reveal]'
  ).on("willDestroyElement")