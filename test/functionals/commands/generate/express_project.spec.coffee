require '../../../test_helper'

Neat = require 'neat'
{run} = Neat.require 'utils/commands'

describe 'when outside a project', ->
  beforeEach -> process.chdir FIXTURES_ROOT

  describe 'running `neat generate express:project`', ->
    it "should return a status of 1 and don't generate anything", (done) ->
      run 'node', [NEAT_BIN, 'generate', 'express:project'], (status) ->
        expect(status).toBe(1)
        done()

withExpressProject 'express_project', ->
  it 'should have created the expected content', ->
    expect(inProject 'assets/.gitkeep').toExist()
    expect(inProject 'src/app/controllers/.gitkeep').toExist()
    expect(inProject 'src/app/models/.gitkeep').toExist()
    expect(inProject 'templates/views/.gitkeep').toExist()

    expect(inProject 'src/config/routes.coffee').toExist()
