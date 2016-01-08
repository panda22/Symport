LD.utils = Ember.Namespace.create()

LD.utils.tap = (o, f) ->
  f o
  o


LD.utils.resolveClass = (name) ->
  found = LabCompass[name]
  if Ember.typeOf(found) != "class"
    Ember.assert "Expected 'LabCompass.#{name}' to be a class"
  found

LD.utils.ensureInstance = (nameOrClass, object) ->
  if Ember.typeOf(object) != "instance"
    type = if Ember.typeOf(nameOrClass) == "string"
      LD.utils.resolveClass nameOrClass
    else
      nameOrClass
    type.create object
  else
    object
