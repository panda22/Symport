moduleFor "comparator:numericalrange", "Number comparator"

test "check the operations", ->
  subject = @subject()

  ok subject.compute("<", "20", "30")
  ok !subject.compute("<", "30", "20")

  ok subject.compute("<=", "20", "30")
  ok subject.compute("<=", "30", "30")
  ok subject.compute("<=", "40", "200")
  ok !subject.compute("<=", "30", "20")

  ok !subject.compute(">", "5", "200")
  ok subject.compute(">", "20", "10")
  ok !subject.compute(">", "30", "30")

  ok !subject.compute(">=", "20", "30")
  ok subject.compute(">=", "30", "30")
  ok subject.compute(">=", "30", "20")
  ok !subject.compute(">=", "5", "200")

  ok subject.compute("=", "20", "20")
  ok !subject.compute("=", "30", "20")

  ok !subject.compute("<>", "20", "20")
  ok subject.compute("<>", "30", "20")