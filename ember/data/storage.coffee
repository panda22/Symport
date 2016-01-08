LD.Storage = Ember.Object.extend

  interfaceName: Ember.required()

  interface: (->
    @container.lookup("storage-interface:#{@get "interfaceName"}")
  ).property "interfaceName"

  createModel: (nameOrClass, properties = {}) ->
    modelClass = if Ember.typeOf(nameOrClass) == "class"
      nameOrClass
    else
      @findModel nameOrClass
    modelClass._create
      storage: @
      container: @container
    .tap (model) =>
      model.setProperties properties
      model._verifyRequiredFields()
      model.awaken()

  createRelationshipArray: (modelName, content) ->
    array = LD.RelationshipArray.create content: content, storage: @
    array.set "model", modelName
    array

  findModel: (name) ->
    @container.lookupFactory "model:#{name}"

  ensureModel: (name, object) ->
    if Ember.typeOf(object) != "instance"
      @createModel name, object
    else
      object

  ensureSpecificModel: (name, object = {}) ->
    modelClass = @findModel name
    if name && object
      if Ember.typeOf(object) != "instance"
        @createModel name, object
      else
        if object.constructor == modelClass
          object
        else
          @createModel name
    else
      null

  deserialize: (type, value) ->
    if Ember.isEmpty(type)
      type = "_default"

    t = @container.lookup("transform:#{type}") || @container.lookup("transform:_default")
    t.deserialize value

  serialize: (type, value) ->
    if Ember.isEmpty(type)
      type = "_default"

    t = @container.lookup("transform:#{type}") || @container.lookup("transform:_default")
    t.serialize value
