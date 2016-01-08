attr = LD.attr
hasMany = LD.hasMany
hasOne = LD.hasOne

LabCompass.TestModel = LD.Model.extend
  number: attr "number", required: true, default: 5, readOnly: true
  simple: attr "boolean", default: true
  cousin: hasOne "OtherTestModel"
  chillins: hasMany "ChildTestModel"
  numBar: (->
    @get('number') + 1
  ).property 'number'

LabCompass.OtherTestModel = LD.Model.extend
  nickname: attr "string", default: 'Bob'
  momSide: attr "boolean", default: true

LabCompass.ChildTestModel = LD.Model.extend
  age: attr "number", required: true

container = null

storage = null

module "LabCompass.Model",
  setup: ->

    container = LabCompass.__container__
    # container.register "storage:main", LabCompass.Storage
    # container.register "storage-interface:server", LabCompass.ServerInterface
    # container.register "model:testModel", TestModel
    # container.register "model:otherTestModel", OtherTestModel
    # container.register "model:childTestModel", ChildTestModel
    storage = container.lookup("storage:main")

test "default value / computed property", ->
  model = storage.createModel "testModel", number: 3
  equal model.get('number'), 3
  equal model.get('numBar'), 4
  model = storage.createModel "testModel"
  equal model.get('number'), 5
  equal model.get('numBar'), 6

test "required property", ->
  model = storage.createModel "childTestModel", age: 4
  equal model.get('age'), 4
  throws =>
    model = storage.createModel "childTestModel"
  , "bar"

test "read only property", ->
  model = storage.createModel "testModel", number: 4
  throws ->
    model.set 'number', 6
  , "foo"

test "simple value declaration", ->
  model = storage.createModel "testModel"
  equal model.get('simple'), true
  model = storage.createModel "testModel", simple: false
  equal model.get('simple'), false

test "hasOne relationship", ->
  model = storage.createModel "testModel",
    cousin:
      nick_name: 'Jim'
      momSide: false
  cuz = model.get('cousin')
  equal cuz.get('nick_name'), 'Jim'
  cuz2 = storage.createModel "otherTestModel",
    nick_name: 'Jack'
    momSide: true
  model = storage.createModel "testModel", cousin: cuz2
  equal model.get('cousin'), cuz2

test "hasMany relationship", ->
  model = storage.createModel "testModel",
    chillins: [
      {age: 5},
      {age: 10}
    ]
  ages = model.get('chillins').content.map((i) -> i.get('age'))
  deepEqual ages, [5, 10], "ages are equal"
  chil1 = storage.createModel "childTestModel", age: 7
  model = storage.createModel "testModel", chillins: [chil1, age: 6]
  equal model.get('chillins').content[0], chil1, "child 1"
  equal model.get('chillins').content[1].get('age'), 6, "child 2"
