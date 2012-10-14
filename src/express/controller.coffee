
bind = (fn, context) -> -> fn.apply context, arguments

class Controller
  @partialName: -> @name.replace('Controller','').toLowerCase()

  constructor: ->
    @index = @wrap @index

  wrap: (method) ->
    method = bind method, this
    return => method.call null, arguments

module.exports = Controller
