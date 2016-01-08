container = null
storage = null
module "LabCompass.DependentQuestionIdentifier",

  setup: ->
    container = LabCompass.__container__
    storage = container.lookup("storage:main")

test "identifies dependencies", ->
  questionOneData =
    id: "q1id"
    type: "text"
    prompt: "What's your gender?"
    variableName: "var1"
    conditions: []

  questionTwoData =
    id: "q2id"
    type: "text"
    prompt: "What's your age?"
    variableName: "var2"
    conditions: []

  questionThreeData =
    id: "q3id"
    type: "text"
    prompt: "Have you ever been pregnant"
    variableName: "var3"
    conditions: [
      dependsOn: "q1id"
      operator: "="
      value: "Female"
    ]

  questionFourData =
    id: "q4id"
    type: "text"
    prompt: "Question with two dependencies"
    variableName: "var4"
    conditions: [
        dependsOn: "q1id"
        operator: "="
        value: "Female"
      ,
        dependsOn: "q2id"
        operator: ">="
        value: "20"
    ]

  question1 = storage.createModel('formQuestion', questionOneData)
  question2 = storage.createModel('formQuestion', questionTwoData)
  question3 = storage.createModel('formQuestion', questionThreeData)
  question4 = storage.createModel('formQuestion', questionFourData)

  ok !question1.isDependency
  ok !question2.isDependency
  ok !question3.isDependency
  ok !question4.isDependency

  LabCompass.DependentQuestionIdentifier([question1, question2, question3, question4])

  ok question1.isDependency
  ok question2.isDependency
  ok !question3.isDependency
  ok !question4.isDependency