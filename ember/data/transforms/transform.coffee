LD.Transform = Ember.Object.extend

  deserialize: (serialized) ->
    serialized

  serialize: (deserialized) ->
    deserialized

Ember.Application.initializer

  name: "transforms"

  initialize: (container) ->
    container.register "transform:_default", LD.Transform
    container.register "transform:boolean", LD.BooleanTransform
    container.register "transform:string", LD.StringTransform
    container.register "transform:number", LD.NumberTransform
    container.register "transform:date", LD.Transform
