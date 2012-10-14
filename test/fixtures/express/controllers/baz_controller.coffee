
class BazController
  @instancesCount: 0
  @calls = {}

  constructor: ->
    BazController.instancesCount++

  foo: (req, res) ->
    BazController.calls.foo ||= 0
    BazController.calls.foo++

  index: (req, res) ->
    BazController.calls.index ||= 0
    BazController.calls.index++

module.exports = BazController
