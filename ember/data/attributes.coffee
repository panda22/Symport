LD.attr = (type = null, meta = {}) ->
  if Ember.typeOf(meta) != "object"
    meta =
      default: meta
  prop = ((k, v) ->
    if arguments.length > 1
      if type
        v = @storage.deserialize type, v
      if meta.readOnly && @get("__locked")
        Ember.assert "Cannot set read-only property #{k} to #{v}"
      if meta.class
        v = @storage.ensureModel meta.class, v
      @get("errors").remove k
      @_rawWrite k, v
    else
      @_rawRead k, -> meta.default
  ).property().meta(lcRequired: meta.required, lcAttr: true, lcRelationship: meta.relationship, lcType: type || "string")
  prop

LD.hasOne = (relatedObjectName, meta={}) ->
  LD.attr null, Ember.merge(meta, class: relatedObjectName, relationship: true)

LD.hasMany = (model, meta={}) ->
  if Ember.typeOf(meta) != "object"
    meta = {}
  prop = ((k, v) ->
    storage = @_rawRead k, =>
      @storage.createRelationshipArray model, []
    if arguments.length > 1
      storage.set("[]", Ember.A(v))
    else
      storage
  ).property().meta(lcAttr: true, lcRelationship: true)
  prop

LD.hasPolymorphic = (modelDeterminator, dependentKeys...) ->
  meta = {}
  prop = ((k, v) ->
    modelClassName = modelDeterminator.call this
    if arguments.length > 1
      if meta.readOnly && @get("__locked")
        Ember.assert "Cannot set read-only property #{k} to #{v}"
      v = @storage.ensureSpecificModel modelClassName, v
      @_rawWrite k, v
    else
      v = @storage.ensureSpecificModel modelClassName, @_rawRead(k, -> meta.default)
      @_rawWrite k, v
  ).property(dependentKeys...).meta(lcAttr: true, lcRelationship: true)
  prop
