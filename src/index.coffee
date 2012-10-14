{resolve} = require 'path'
Neat = require 'neat'

requireExpress = (resource) -> require "#{__dirname}/express/#{resource}"

Router = requireExpress 'router'

Express =
  require: requireExpress
  root: resolve __dirname, '..'
  loadRoutes: (app) ->
    router = new Router app
    routes = require "#{Neat.root}/lib/config/routes"
    router.routes routes

module.exports = Express
