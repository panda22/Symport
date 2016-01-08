LD.Model = Ember.Object.extend Ember.Copyable,
  awaken: ->
    # This method is called after the model has been fully set-up, including properties
    # Here we simply stub it out.

  _verifyRequiredFields: ->
    @constructor.eachComputedProperty (name, propertyMetadata) =>
      if propertyMetadata.lcRequired
        value = @get name
        Ember.assert "The field #{name} is required", value != undefined
    @set "__locked", true

  tap: (f) ->
    f @; @

  _rawRead: (k, makeDefault = -> null) ->
    (@._data ||= {})[k] ||= makeDefault()

  _rawWrite: (k, v) ->
    (@._data ||= {})[k] = v

  hasID: (->
    !Ember.isEmpty @get('id')
  ).property "id"

  attributes: ->
    attrs = [{name: "id", value: @get('id'), meta: {}}]
    @constructor.eachComputedProperty (name, propertyMetadata) =>
      attrs.addObject name: name, value: @get(name), meta: propertyMetadata
    attrs

  serialize: ->
    serialized = {}
    @attributes().forEach (attr) =>
      if attr.meta.lcAttr || attr.name == 'id'
        serialized[attr.name] = if attr.meta.lcRelationship
          attr.value?.serialize()
        else
          @storage.serialize attr.meta.lcType, attr.value
    serialized

  copy: (deep) ->
    @storage.createModel @constructor, @serialize()

  errors: (->
    errors = LD.Errors.create()
    errors
  ).property().readOnly()

  applyErrors: (errorData) ->
    if errorData
      errors = @get "errors"
      @beginPropertyChanges()
      errors.clear()
      @attributes().forEach (attr) ->
        if attr.meta.lcRelationship
          if attr.value
            childErrors = errorData[attr.name] || {}
            attr.value.applyErrors childErrors
        else
          errors.add attr.name, errorData[attr.name]
      @endPropertyChanges()

# Here we prevent instances from being created directly.
# Instances should only be created via Storage, in order to ensure that they
# can be set up properly.

LD.Model.reopenClass

  _create: LD.Model.create

  create: ->
    throw new Ember.Error "You should not call create() on a model. Instead, create one via storage.createRecord()."
