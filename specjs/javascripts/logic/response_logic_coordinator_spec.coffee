moduleFor "logic:response", "Logic Response Coordinator",
  needs: [
    "storage:main"
    "model:formResponse"
    "model:formStructure"
    "model:formQuestion"
    "model:formAnswer"
    "model:questionCondition"
    "transform:_default"
    "comparator:text"
    "comparator:numericalrange"
    "logic:responseDependency"
  ]
  setup: ->
    @storage = @container.lookup "storage:main"

test "basic logic management", ->
  coordinator = @subject()
  # 1. create a real form response heirarchy that contains some data specifying conditional logic
  formResponseData =
    id: "something"
    subjectID: "VW GTI"
    formStructure:
      id: "fs-id"
      name: "Something cool"
    answers: [
        answer: null
        question:
          id: "q1id"
          type: "text"
          prompt: "What's your gender?"
          variableName: "var1"

          conditions: []
      ,
        answer: null
        question:
          id: "q2id"
          prompt: "Have you ever been pregnant?"
          type: "text"
          variableName: "var2"

          conditions: [
            dependsOn: "q1id"
            operator: "="
            value: "Female"
          ]
      ,
        answer: null
        question:
          id: "q3id"
          prompt: "What's your name?"
          type: "text"
          variableName: "var3"

          conditions: []

    ]
  formResponse = @storage.createModel('formResponse', formResponseData)


  # 2. set the form response on the logic coordinator

  coordinator.set "formResponse", formResponse

  # 3. set a value for an answer that will affect the enabled state of another question
  #- check that the question is disabled
  ok answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "It should start out disabled"
  #- set the answer to female:
  answerForQuestion(formResponse, "q1id").set("answer", "Female")
  #- see that thet question is still enabled
  ok !answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "It should be enabled after setting the gender to female"
  #- set the answer to male:
  answerForQuestion(formResponse, "q1id").set("answer", "Male")
  ok answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "It should be disabled after setting the gender to male"


test "doesn't barf when there are no answers", ->
  coordinator = @subject()
  formResponseData =
    id: "response-with-no-answers"
    subjectID: "007"
    formStructure:
      id: "form-with-no-questions"
      name: "This form has no questions"
    answers: [
    ]

  formResponse = @storage.createModel "formResponse", formResponseData

  coordinator.set "formResponse", formResponse

  deepEqual coordinator.get("dependencies"), [], "There are obviously no dependencies"

test "greater than and less than logic", ->
  coordinator = @subject()

  formResponseData =
    id: "something"
    subjectID: "VW GTI"
    formStructure:
      id: "fs-id"
      name: "Something cool"
    answers: [
        answer: null
        question:
          id: "q1id"
          type: "text"
          prompt: "What's your gender?"
          variableName: "var1"
          conditions: []
      ,
        answer: null
        question:
          id: "q2id"
          prompt: "Have you ever been pregnant?"
          variableName: "var2"
          type: "text"
          conditions: [
            dependsOn: "q1id"
            operator: "<>"
            value: "Male"
          ]
      ,
        answer: null
        question:
          id: "q3id"
          prompt: "What's your name?"
          type: "text"
          variableName: "var3"
          conditions: []
      ,
        answer: null
        question:
          id: "q4id"
          prompt: "What's your favorite number?"
          variableName: "var4"
          type: "numericalrange"
          conditions: []
      ,
        answer: null
        question:
          id: "q5id"
          prompt: "dependent question"
          variableName: "var5"
          type: "text"
          conditions: [
              dependsOn: "q4id"
              operator: "<"
              value: "50"
            ,
              dependsOn: "q4id"
              operator: ">="
              value: "5"
          ]

    ]
  formResponse = @storage.createModel('formResponse', formResponseData)

  # 2. set the form response on the logic coordinator

  coordinator.set "formResponse", formResponse

  # 3. set a value for an answer that will affect the enabled state of another question
  #- check that the question is disabled


  ok !answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "Q2 should start out enabled"
  #- set the answer to female:
  answerForQuestion(formResponse, "q1id").set("answer", "Female")
  #- see that thet question is still enabled
  ok !answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "Q2 should be enabled after setting the gender to female"
  #- set the answer to male:
  answerForQuestion(formResponse, "q1id").set("answer", "Male")
  ok answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "Q2 should be disabled after setting the gender to male"


  ok answerForQuestion(formResponse, "q5id").get('conditionallyDisabled'), "Q5 should start as disabled"
  answerForQuestion(formResponse, "q4id").set("answer", 30)
  ok !answerForQuestion(formResponse, "q5id").get('conditionallyDisabled'), "Q5 should be enabled after setting a value between 5 and 30 for Q4"

  answerForQuestion(formResponse, "q4id").set("answer", 60)
  ok answerForQuestion(formResponse, "q5id").get('conditionallyDisabled'), "Q5 should be disabled after setting a value out of range for Q4"

  answerForQuestion(formResponse, "q4id").set("answer", 4)
  ok answerForQuestion(formResponse, "q5id").get('conditionallyDisabled'), "Q5 should be disabled after setting a value out of range for Q4"

  answerForQuestion(formResponse, "q4id").set("answer", 5)
  ok !answerForQuestion(formResponse, "q5id").get('conditionallyDisabled'), "Q5 should be enabled after setting a correct value for Q4"


 test "multiple condition questions for a single question", ->
  coordinator = @subject()
  # 1. create a real form response heirarchy that contains some data specifying conditional logic
  formResponseData =
    id: "something"
    subjectID: "VW GTI"
    formStructure:
      id: "fs-id"
      name: "Something cool"
    answers: [
        answer: null
        question:
          id: "q1id"
          type: "text"
          prompt: "What's your gender?"
          variableName: "var1"

          conditions: []
      ,
        answer: null
        question:
          id: "q2id"
          prompt: "What's your age?"
          type: "numericalrange"
          variableName: "var2"

      ,
        answer: null
        question:
          id: "q3id"
          prompt: "Are you a boy scout?"
          type: "text"
          variableName: "var3"

          conditions: [
            dependsOn: "q1id"
            operator: "="
            value: "Male"
          ,
            dependsOn: "q2id"
            operator: "<="
            value: "12"
          ]

    ]
  formResponse = @storage.createModel('formResponse', formResponseData)

  # 2. set the form response on the logic coordinator

  coordinator.set "formResponse", formResponse

  # 3. set a value for an answer that will affect the enabled state of another question

  ok answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should start out disabled"

  answerForQuestion(formResponse, "q1id").set("answer", "Male")
  ok answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should still be disabled"

  answerForQuestion(formResponse, "q2id").set("answer", "8")
  ok !answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should be enabled"

  answerForQuestion(formResponse, "q1id").set("answer", "Female")
  ok answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should now be disabled"

test "chained dependency logic management", ->
  coordinator = @subject()
  # 1. create a real form response heirarchy that contains some data specifying conditional logic
  formResponseData =
    id: "something"
    subjectID: "VW GTI"
    formStructure:
      id: "fs-id"
      name: "Something cool"
    answers: [
        answer: null
        question:
          id: "q1id"
          type: "text"
          prompt: "What's your gender?"
          variableName: "var1"

          conditions: []
      ,
        answer: null
        question:
          id: "q2id"
          prompt: "Are you pregnant?"
          type: "text"
          variableName: "var2"

          conditions: [
            dependsOn: "q1id"
            operator: "="
            value: "Female"
          ]
      ,
        answer: null
        question:
          id: "q3id"
          prompt: "What are you going to name the baby?"
          type: "text"
          variableName: "var3"

          conditions: [
            dependsOn: "q2id"
            operator: "="
            value: "Yes"
          ]

    ]
  formResponse = @storage.createModel('formResponse', formResponseData)

  # 2. set the form response on the logic coordinator
  coordinator.set "formResponse", formResponse

  # 3. the second and third questions should be disabled
  ok answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "Q2 should start disabled"
  ok answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should start disabled"

  # 4. enable the second question
  answerForQuestion(formResponse, "q1id").set("answer", "Female")
  ok !answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "Q2 should become enabled"
  ok answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should stay disabled"

  # 5. enable the third question
  answerForQuestion(formResponse, "q2id").set("answer", "Yes")
  ok !answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should become enabled"

  # 6. answer the third question
  answerForQuestion(formResponse, "q3id").set("answer", "Rumplestilskin")

  # 7. disabling the second question should disable the third question
  answerForQuestion(formResponse, "q1id").set("answer", "Male")
  ok answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "Q2 should become disabled"
  ok answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should become disabled"

  # 8. re-enabling the questions should persist old answers
  answerForQuestion(formResponse, "q1id").set("answer", "Female")
  ok !answerForQuestion(formResponse, "q2id").get('conditionallyDisabled'), "Q2 should become disabled"
  equal "Yes", answerForQuestion(formResponse, "q2id").get("answer")
  ok !answerForQuestion(formResponse, "q3id").get('conditionallyDisabled'), "Q3 should become disabled"
  equal "Rumplestilskin", answerForQuestion(formResponse, "q3id").get("answer")



answerForQuestion = (formResponse, questionID) ->
  formResponse.get("answers").findBy('question.id',questionID)
