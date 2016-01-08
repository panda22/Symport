#assumes input or textarea
#selects all text when focused

LabCompass.SelectTextOnFocusMixin = Ember.Mixin.create
  
  setFocusSelectTextListener: (->
    @$().focus =>
      if @get("selectOnFocus")
        Ember.run.next =>
          @$().select()
  ).on('didInsertElement')

