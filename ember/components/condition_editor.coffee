#controls the logic and value part of a peice of conditional logic
#question: the question being targeted with conditions
#condition: QuestionCondition model from parent question so that changes in this condition are reflected in question

LabCompass.ConditionEditorComponent = Ember.Component.extend
  question: null
  condition: null
  disabled: false

  comparator: ( ->
    conditionQuestion = @get "question"
    if conditionQuestion
      @container.lookup "comparator:#{conditionQuestion.get("type")}"
    else
      null
  ).property "question.type"

  supportedOperators: Ember.computed.readOnly "comparator.supportedOperators"

  whenOperatorsChange: (->
    if !((@get("supportedOperators") || []).find (item) => item.operator == @get "condition.operator")
      @set "condition.operator", @get("supportedOperators.firstObject.operator")
  ).observes("supportedOperators").on "init"
