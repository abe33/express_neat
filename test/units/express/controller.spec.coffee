require '../../test_helper'

Controller = require '../../../lib/express/controller'

describe 'A class TestController that extends Controller', ->
  beforeEach ->
    calls = {}
    class TestController extends Controller
      @after
      index: ->
        calls.index =
          context: this
          arguments: arguments

    @calls = calls
    @controllerClass = TestController
    @controller = new TestController
    @indexFunction = TestController::index

  it 'should be able to return its partial name', ->
    expect(@controllerClass.partialName()).toBe('test')

  it 'should have its index method been wrapped', ->
    expect(@controller.index).not.toBe(@indexFunction)
    @controller.index()
    expect(@calls.index.context).toBe(@controller)


