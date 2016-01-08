QuestionTypes = Ember.Object.extend
  types: []

  isFormattingType: (type) ->
    @get("types").findBy("type", type).isFormatting == true

  questionTypes: ( ->
    @get("types").map (type) ->
      name: type.name
      type: type.type
      hint: type.hint
  ).property "types.@each.name", "types.@each.type", "types.@each.hint"

  eachRegistration: (cb) ->
    types = @get "types"

    send = (DIKey, objectType) ->
      if !!DIKey && !!objectType && cb
        cb DIKey, objectType

    send "answerUI:filtered", LabCompass.AnswerFiltered

    @get("types").forEach (type) ->
      send "questionUI:#{type.type}", type.questionEdit
      send "answerUI:#{type.type}.edit", type.answerEdit
      send "answerUI:#{type.type}.view", type.answerView || LabCompass.AnswerTextValueViewer
      if !Ember.isEmpty type.questionOperandEdit
        send "questionUI:#{type.type}.operand", type.questionOperandEdit
      if !Ember.isEmpty type.comparator
        send "comparator:#{type.type}", type.comparator
      send "formatter:#{type.type}", type.formatter || LabCompass.TextFormatter


Ember.Application.initializer
  name: "question_type_loading"

  initialize: (container, app) ->
    LabCompass.QuestionTypes = QuestionTypes.create
      types: [
          type: "text"
          name: "Text Field"
          hint: "This question type will create a text field that resizes to fit any amount of text."
          questionOperandEdit: LabCompass.OperandTextEditor
          questionEdit: LabCompass.QuestionEditorTextFields
          answerEdit: LabCompass.AnswerTextEditor
          comparator: LabCompass.TextComparator
        ,
          type: "date"
          name: "Date Field"
          hint: "This question type will create a mm/dd/yyyy field intended for a date."
          questionOperandEdit: LabCompass.OperandDateEditor
          questionEdit: LabCompass.QuestionEditorDefaultFields
          answerEdit: LabCompass.AnswerDateEditor
          comparator: LabCompass.DateComparator
        ,
          type: "zipcode"
          name: "Zipcode"
          hint: "This question type will create a ‘#####’ field intended for a five digit zip code."
          questionOperandEdit: LabCompass.OperandZipcodeEditor
          questionEdit: LabCompass.QuestionEditorDefaultFields
          answerEdit: LabCompass.AnswerZipcodeEditor
          comparator: LabCompass.EqualityComparator
        ,
          type: "checkbox"
          name: "Checkbox (select many)"
          hint: "This question type will create a list of answer choices, zero or more of which may be selected."
          questionOperandEdit: LabCompass.OperandSelectionEditor
          questionEdit: LabCompass.QuestionEditorOptionsFields
          answerEdit: LabCompass.AnswerCheckboxesEditor
          answerView: LabCompass.AnswerCheckboxesViewer
          comparator: LabCompass.CheckboxComparator
          formatter: LabCompass.CheckboxesFormatter
        ,
          type: "radio"
          name: "Multiple Choice (select one)"
          hint: "This question type will create a list of answer choices, only one of which can be selected"
          questionOperandEdit: LabCompass.OperandSelectionEditor
          questionEdit: LabCompass.QuestionEditorOptionsFields
          answerEdit: LabCompass.AnswerRadioButtonsEditor
          comparator: LabCompass.RadioComparator
        ,
          type: "dropdown"
          name: "Dropdown"
          hint: "This question type will create a list of answer choices, only one of which can be selected"
          questionOperandEdit: LabCompass.OperandSelectionEditor
          questionEdit: LabCompass.QuestionEditorOptionsFields
          answerEdit: LabCompass.AnswerDropdownEditor
          comparator: LabCompass.EqualityComparator
        ,
          type: "email"
          name: "Email"
          hint: "This question type will create an 'abc@xyz.com' field intended for an email address."
          questionOperandEdit: LabCompass.OperandTextEditor
          questionEdit: LabCompass.QuestionEditorDefaultFields
          answerEdit: LabCompass.AnswerEmailEditor
          comparator: LabCompass.TextComparator
        ,
          type: "yesno"
          name: "Yes/No"
          hint: "This question type will create a yes or no question."
          questionOperandEdit: LabCompass.OperandSelectionEditor
          questionEdit: LabCompass.QuestionEditorYesNoFields
          answerEdit: LabCompass.AnswerRadioButtonsEditor
          comparator: LabCompass.EqualityComparator
        ,
          type: "timeofday"
          name: "Time of day"
          hint: "This question type will create a field intended for the time of day in hours and minutes."
          questionOperandEdit: LabCompass.OperandTimeOfDayEditor
          questionEdit: LabCompass.QuestionEditorDefaultFields
          answerEdit: LabCompass.AnswerTimeOfDayEditor
          comparator: LabCompass.TimeOfDayComparator
        ,
          type: "timeduration"
          name: "Time duration"
          hint: "This question type will create a field intended for an amount of time in hours, minutes, and seconds"
          questionOperandEdit: LabCompass.OperandTimeDurationEditor
          questionEdit: LabCompass.QuestionEditorDefaultFields
          answerEdit: LabCompass.AnswerTimeDurationEditor
          comparator: LabCompass.TimeDurationComparator
          formatter: LabCompass.TimeDurationFormatter
        ,
          type: "numericalrange"
          name: "Number"
          hint: "This question type will create a field that accepts a number. You may specify a range and precision."
          questionOperandEdit: LabCompass.OperandNumericalRangeEditor
          questionEdit: LabCompass.QuestionEditorNumericalRangeFields
          answerEdit: LabCompass.AnswerNumericalRangeEditor
          comparator: LabCompass.NumericalRangeComparator
        ,
          type: "phonenumber"
          name: "Phone number"
          hint: "This question will create a ‘### - ### - ####’ field intended for a phone number."
          questionOperandEdit: LabCompass.OperandPhoneNumberEditor
          questionEdit: LabCompass.QuestionEditorDefaultFields
          answerEdit: LabCompass.AnswerPhoneNumberEditor
          comparator: LabCompass.TextComparator
        ,
          type: "header"
          name: "Header"
          hint: "This question type will create a header, usually used to indicate the start of a new section."
          questionEdit: LabCompass.QuestionHeaderFields
          answerEdit: LabCompass.AnswerHeader
          answerView: LabCompass.AnswerHeader
          isFormatting: true
        # ,
        #   type: "pagebreak"
        #   name: "Page Break"
        #   hint: null
        #   questionEdit: LabCompass.QuestionPageBreakFields
        #   answerEdit: LabCompass.AnswerPageBreak
        #   answerView: LabCompass.AnswerPageBreak
        #   isFormatting: true
      ]

    LabCompass.QuestionTypes.eachRegistration (name, editor) ->
      app.register name, editor, singleton: false
