#Ember.textfield with parent highlighting on focus
#highlightParentDepth: if specified, highlights parent at specified depth on focus
#takeFocus: if true, elemnt will take focus on didInsert
LabCompass.highlightParentTextField = Ember.TextField.extend LabCompass.HighlightParentMixin, LabCompass.TakeFocusMixin

