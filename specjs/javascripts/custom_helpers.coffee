window.moduleForLDModel = (name, description, callbacks) ->
  moduleFor "model:#{name}", description, callbacks, (container, context, defaultSubject) ->
    container.register "storage:main", LabCompass.Storage
    # TODO register only used transforms, also register referred models
    container.register "transform:_default", LD.Transform
    container.register "transform:boolean", LD.BooleanTransform
    container.register "transform:string", LD.StringTransform
    container.register "transform:number", LD.NumberTransform
    container.register "transform:date", LD.Transform

    if context.__setup_properties__.subject == defaultSubject
      context.__setup_properties__.subject = (options) ->
        container.lookup('storage:main').createModel(name, options)

window.moduleForController = (name, description, callbacks) ->
  if callbacks
    if callbacks.model
      callbacks.needs = ["model:#{callbacks.model}"].concat(callbacks.needs || [])
  moduleFor "controller:#{name}", description, callbacks, (container, context, defaultSubject) ->
    container.register "storage:main", LabCompass.Storage
    container.injection "controller", "storage", "storage:main"
    # TODO register only used transforms, also register referred models
    container.register "transform:_default", LD.Transform
    container.register "transform:boolean", LD.BooleanTransform
    container.register "transform:string", LD.StringTransform
    container.register "transform:number", LD.NumberTransform
    container.register "transform:date", LD.Transform

    # TODO
    # I tried to make a storage() helper, but it seemed to conflict
    # somehow with the 'storage' for the controller.  Sometimes it 
    # would be the same instance, sometimes not

    if context.__setup_properties__.subject == defaultSubject
      context.__setup_properties__.subject = (options, factory) ->
        storage = container.lookup('storage:main')
        controller = factory.create()
        if callbacks
          if callbacks.model
            model = storage.createModel(callbacks.model, options)
            controller.set('content', model)
          if callbacks.target
            controller.set('target', callbacks.target)
        controller
