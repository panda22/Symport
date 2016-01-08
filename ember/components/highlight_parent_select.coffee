#Ember.select with parent highlighting on focus
#highlightParentDepth: if specified, highlights parent at specified depth on focus
#takeFocus: if true, elemnt will take focus on didInsert
LabCompass.highlightParentSelect = Ember.Select.extend LabCompass.HighlightParentMixin, LabCompass.TakeFocusMixin