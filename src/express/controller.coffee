
CRUD = ['index', 'show', 'edit', 'update', 'create', 'destroy', 'new']
bind = (fn, context) -> -> fn.apply context, arguments

class Controller
  @partialName: -> @name.replace('Controller','').toLowerCase()
  @crud: CRUD

  constructor: ->
    for key in Controller.crud
      @[key] = @wrap @[key]

  wrap: (method) ->
    method = bind method, this
    return => method.call null, arguments

module.exports = Controller
