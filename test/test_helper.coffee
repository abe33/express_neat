Neat = require 'neat'
Neat.require 'core'
{run} = Neat.require 'utils/commands'
{ensurePath} = Neat.require 'utils/files'

require "#{Neat.neatRoot}/test/test_helper"

Express = require '../lib'

global.withExpressBundledProject = (name, block, opts) ->
  opts ||= {}
  init = opts.init

  opts.init = (callback) ->
    args = [
      '-s',
      Express.root,
      inProject('node_modules/express_neat')
    ]
    ensurePath inProject('node_modules'), ->
      run 'ln', args, (status) ->
        if init?
          init callback
        else
          callback?()

  withBundledProject name, block, opts

global.withExpressProject = (name, block, opts) ->
  opts ||= {}
  init = opts.init

  opts.init = (callback) ->
    ensurePath inProject('node_modules'), ->
      run 'node', [NEAT_BIN, 'generate', 'express:project'], (status) ->
        expect(status).toBe(0)
        if init?
          init callback
        else
          callback?()

  withExpressBundledProject name, block, opts

