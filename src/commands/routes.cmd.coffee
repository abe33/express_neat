Neat = require 'neat'
Express = require '..'

{error} = Neat.require 'utils/logs'
{aliases, describe, environment, usages} = Neat.require 'utils/commands'
{render} = Neat.require 'utils/templates'

routes = (pr) ->
  return error "No program provided to routes" unless pr?

  aliases 'routes',
  environment 'production',
  describe 'TODO: Description goes here',
  cmd = (args..., callback) ->
    router = Express.loadRoutes()
    map = router.routesMap
    list = []

    maxPathLength = 0
    for method, controllers of map
      for path, controller of controllers
        o = {method, path}
        maxPathLength = Math.max(maxPathLength, path.length)

        if typeof controller.controller is 'function'
          o.controller = '[Function]'
        else
          o.controller = "#{controller.controller}##{controller.action}"
        list.push o

    list.sort (a,b) ->
      if a.path > b.path then 1 else if b.path > a.path then -1 else 0

    render __filename, {list, maxPathLength}, (err, res) ->
      throw err if err?

      console.log res
      callback?()

module.exports = {routes}
