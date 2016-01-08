moduleFor "comparator:text", "Text answer comparator"

test "check equality", ->
  subject = @subject()

  ok subject.compute("=", "20", "20"), "It should be equal"
  ok !subject.compute("=", "20", "30"), "It shouldn't be equal"

test "check inequality", ->
  subject = @subject()

  ok subject.compute("<>", "20", "30"),  "It should be inequal"
  ok !subject.compute("<>", "20", "20"), "It shouldn't be inequal"


