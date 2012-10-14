fs = require 'fs'
Neat = require 'neat'
express = require 'express'

{error, green, info, puts, red} = Neat.require 'utils/logs'
{aliases, describe, environment, usages} = Neat.require 'utils/commands'
_ = Neat.i18n.getHelper()

Router = require '../express/router'

routes = require "#{Neat.root}/lib/config/routes"

lockPath = "#{Neat.root}/.serverlock"
lock = -> fs.writeFileSync lockPath
locked = -> fs.existsSync lockPath
unlock = -> fs.unlinkSync lockPath

trap = (signals...) ->
  for signal in signals
    process.on signal, ->
      m = red _ 'neat.express.errors.server_terminated', {signal}
      puts m, 5
      unlock()
      process.exit 1

server = (pr) ->
  return error "No program provided to server" unless pr?

  aliases 'server', 's',
  describe 'Runs a server using express.js',
  cmd = (args..., callback) ->
    return error red _('neat.express.errors.server_running') if locked()
    lock()

    {port} = Neat.config.server
    app = express()
    app.use express.bodyParser()
    app.use express.methodOverride()

    trap 'SIGTERM', 'SIGKILL', 'SIGINT'
    process.on 'uncaughtException', (e) ->
      unlock()
      process.exit 1

    router = new Router app
    router.routes routes

    app.listen port
    info green _ 'neat.express.server_started', {port}

module.exports = {server}
