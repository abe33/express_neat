
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

        @render "#{key} was called"

      genControllerNoRenderMethod = (key) -> ->
        calls[key] =
          context: this
          arguments: arguments

      class TestController extends Controller
        @after 'afterFilter', only: 'index'
        @before 'beforeFilter', except: ['show', 'update']

        for key in CRUD
          TestController::[key] = genControllerMethod key

        edit: genControllerNoRenderMethod 'edit'

        constructor: ->
          @afterCalls = 0
          @beforeCalls = 0
          super()

        afterFilter: -> @afterCalls++
        beforeFilter: -> @beforeCalls++

      @calls = calls
      @controllerClass = TestController
      @controller = new TestController

    block.call this

global.request = (options) ->
  request =
    params: []
    body: {}
    originalMethod: 'GET'
    route:
      method: 'get'
      path: '/'
      keys: []
      regexp: /^\/\/?$/i
      params: []

  request.merge options

global.response = (options) ->
  response =
    send: ->

  response.merge options
