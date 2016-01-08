LD.NumberTransform = LD.Transform.extend

  deserialize: (serialized) ->
    Number serialized

  serialize: (deserialized) ->
    Number deserialized

