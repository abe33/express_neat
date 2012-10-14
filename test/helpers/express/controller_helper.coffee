
Controller = require '../../../lib/express/controller'

global.CRUD = ['index', 'show', 'edit', 'update', 'create', 'destroy', 'new']

global.withTestController = (block) ->
  describe 'A class TestController that extends Controller', ->
    beforeEach ->
      calls = {}
      genControllerMethod = (key) -> ->
        calls[key] =
          context: this
          arguments: arguments

      class TestController extends Controller
        for key in CRUD
          TestController::[key] = genControllerMethod key

      @calls = calls
      @controllerClass = TestController
      @controller = new TestController

    block.call this
