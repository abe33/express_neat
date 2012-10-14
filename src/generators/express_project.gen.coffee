{resolve, basename, extname} = require 'path'

Neat = require 'neat'
{puts, error, warn, missing, green, notOutsideNeat} = Neat.require "utils/logs"
{ensureSync, touchSync} = Neat.require "utils/files"
{namespace} = Neat.require "utils/exports"
{renderSync:render} = Neat.require "utils/templates"
{usages, describe, hashArguments} = Neat.require "utils/commands"
_ = Neat.i18n.getHelper()

usages 'neat generate express:project',
describe _('neat.commands.generate.express_project.description'),
project = (generator, args..., callback) ->
  throw new Error notOutsideNeat process.argv.join " " unless Neat.root?

  args.push callback if args.length is 0 and typeof callback isnt 'function'

  tplpath = resolve __dirname, "express"

  context = if args.empty() then {} else hashArguments args

  dirs = [
    "#{Neat.root}/assets"
    "#{Neat.root}/src/app"
    "#{Neat.root}/src/app/controllers"
    "#{Neat.root}/src/app/models"
    "#{Neat.root}/templates/views"
  ]
  files = [
    ["#{Neat.root}/assets/.gitkeep"]
    ["#{Neat.root}/src/app/controllers/.gitkeep"]
    ["#{Neat.root}/src/app/models/.gitkeep"]
    ["#{Neat.root}/templates/views/.gitkeep"]

    ["#{Neat.root}/src/config/routes.coffee", 'routes']
  ]

  t = (a, b) ->
    touchSync a, (if b then render resolve(tplpath, b) else ''), context
    puts green(_('neat.commands.generate.project.generation_done', path: a)), 1

  e = (d) ->
    ensureSync d
    puts green(_('neat.commands.generate.project.generation_done', path: d)), 1

  try
    e d for d in dirs
    t a,b for [a,b] in files
  catch e
    e.message = _('neat.commands.generate.express_project.generation_failed',
                   message: e.message)
    throw e

    callback?()


module.exports = namespace 'express', {project}
