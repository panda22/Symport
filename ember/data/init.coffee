#= require_self
#= require ./transforms/transform

window.LD = Ember.Namespace.create()

Ember.Application.initializer
  name: "ld-transform"
  initialize: (container) ->
    container.register "transform:boolean", LD.BooleanTransform