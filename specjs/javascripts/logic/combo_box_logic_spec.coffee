moduleFor "combo-box:logic"

test "we can give it some options", ->
  @subject().set "allOptions", ["hello", "there"]
  equal @subject().get("options.firstObject.displayValue"), "hello", "The first object should be hello"

test "Options get sorted", ->
  logic = @subject()
  logic.set "allOptions", ["hello", "42", "this", "is", "dog"]
  deepEqual displayValues(logic), ["42", "dog", "hello", "is", "this"], "The options were out of order"

test "Selection property changes as the index changes", ->
  expect 4
  logic = @subject()
  logic.set "allOptions", ["alpha", "beta", "carotene"]
  ok logic.get("options.firstObject.selected"), "The first item should be selected automatically"
  logic.set "selectedIndex", 1
  ok !logic.get("options.firstObject.selected"), "Now the first object should no longer be selected"
  ok logic.get("options").objectAt(1).get("selected"), "Now the second object should be selected"
  ok !logic.get("options").objectAt(2).get("selected"), "Third should no longer be selected"

test "selectNext/selectPrevious change the selections appropriately", ->
  expect 5
  logic = @subject()
  logic.set "allOptions", "a b c".split(" ")
  logic.selectNext()
  equal logic.get("selectedOption.displayValue"), "b", "The second option should be selected"
  logic.selectNext()
  equal logic.get("selectedOption.displayValue"), "c", "The third option should be selected"
  logic.selectNext()
  equal logic.get("selectedOption.displayValue"), "c", "We shouldn't be able to move past the last element"
  logic.selectPrevious()
  equal logic.get("selectedOption.displayValue"), "b", "Move back to b"
  logic.selectPrevious()
  logic.selectPrevious()
  logic.selectPrevious()
  equal logic.get("selectedOption.displayValue"), "a", "We can't move before the first element"


test "filter gets applied and resets selection", ->
  expect 5
  logic = @subject()

  logic.set "allOptions", "hey hello hellooo heinous ouch oyyy burritos".split(" ")
  equal 7, logic.get("options.length"), "Before filtering, we should see all options"
  logic.set "filter", "he"
  deepEqual displayValues(logic), "heinous hello hellooo hey".split(" "), "Filter by `he`"
  equal "heinous", logic.get("selectedOption.value"), "The selected option should automatically update"

  logic.set "filter", "o"
  deepEqual displayValues(logic), "ouch oyyy".split(" "), "Filter by `o`"
  equal "ouch", logic.get("selectedOption.value"), "The selection was reset to the first object"

test "filtering is robust (case insensitive)", ->
  logic = @subject()

  logic.set "allOptions", "HeLLo hey HEyo wat".split(" ")
  logic.set "filter", "hE"
  deepEqual displayValues(logic), "HeLLo hey HEyo".split(" "), "Filtering should be case insensitive"

test "selectedOption is readwrite", ->
  expect 12
  logic = @subject()

  logic.set "allOptions", "aa ab bb".split(" ")
  logic.set "filter", "a"

  aa = logic.get("options").objectAt 1
  ab = logic.get("options").objectAt 2
  bb = logic.get("allOptionsObjects.lastObject")

  equal "aa", aa.get("displayValue"), "The first object should be aa"
  equal "ab", ab.get("displayValue"), "The last object should be ab"
  equal "bb", bb.get("displayValue"), "We should have an object for bb"

  ok aa.get("selected"), "aa is selected"
  ok !ab.get("selected"), "ab is not selected"

  equal 1, logic.get("selectedIndex"), "The selected index is initially 1"
  logic.set "selectedOption", ab
  equal 2, logic.get("selectedIndex"), "The selected index changes after setting"

  ok !aa.get("selected"), "aa is now not selected"
  ok ab.get("selected"), "ab is now selected"

  logic.set "selectedOption", bb

  ok ab.get("selected"), "ab is still selected"
  ok !bb.get("selected"), "bb should not be selected"
  equal "ab", logic.get("selectedOption.displayValue"), "the selectedOption is still good"

test "generate a Create New option when there is no exact match", ->
  expect 4
  logic = @subject()

  logic.set "allOptions", "aa aaba bbc".split(" ")

  logic.set "filter", "A"
  deepEqual displayValues(logic, true), ["+ Create New", "aa", "aaba"], "include Create new option"
  equal logic.get("options.firstObject.value"), "A", "The create new option has the underlying value of the filter"

  logic.set "filter", "Aa"
  deepEqual displayValues(logic, true), ["aa", "aaba"], "don't show Create New option with exact match"
  equal logic.get("options.firstObject.value"), "aa", "The create new option doesn't exist"

test "it selects the Create New option as a last resort", ->
  expect 7

  logic = @subject()

  logic.set "allOptions", "ab ac ad".split(" ")

  logic.set "filter", "a"
  equal "ab", logic.get("selectedOption.displayValue"), "The current best option should be selected"

  logic.set "filter", "ab"
  equal "ab", logic.get("selectedOption.displayValue"), "Should still be selected"

  logic.set "filter", "abc"
  equal "+ Create New", logic.get("selectedOption.displayValue"), "Now the Create New option should be selected"
  equal 0, logic.get("selectedIndex"), "The index should be zero"
  equal logic.get("selectedOption"), logic.get("options.firstObject"), "these should be the same object!"
  ok logic.get("selectedOption.selected"), "The selected property should be true"
  ok logic.get("options.firstObject.selected"), "The selected property should also be on the first object of options"

test "it omits the Create New option if specified as omitted", ->
  logic = @subject()

  logic.set "allowCreate", false
  logic.set "allOptions", "ab ac ad".split(" ")

  logic.set "filter", "a"
  deepEqual ["ab", "ac", "ad"], displayValues(logic, true), "There should be no create option"

  logic.set "filter", "ab"
  deepEqual ["ab"], displayValues(logic, true), "There should be no create option"

  logic.set "filter", "abc"
  deepEqual [], displayValues(logic, true), "Even with nothing selected, there is no create option"


displayValues = (logic, includeCreate = false) ->
  options = logic.get("options").mapBy("displayValue")
  if options.objectAt(0) == "+ Create New" && !includeCreate
    options = options.slice 1
  options
