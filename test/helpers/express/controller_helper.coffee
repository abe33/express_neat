Neat = require 'neat'
Controller = require '../../../lib/express/controller'

hamlcInit = Neat.require 'config/initializers/templates/haml_coffee'

global.CRUD = ['index', 'show', 'edit', 'update', 'create', 'destroy', 'new']

global.withTestController = (block) ->
  describe 'A class TestController that extends Controller', ->
    beforeEach ->

      Neat.config =
        templatesDirectoryName: 'test/fixtures/templates'
        engines:
          templates: 
            hamlc: null

      hamlcInit Neat.config

      calls = {}
      genViewMethod = (key) -> ->
        calls[key] =
          context: this
          arguments: arguments

        @render "#{key} was called"

      genViewNoRenderMethod = (key) -> ->
        calls[key] =
          context: this
          arguments: arguments

      # genViewRenderWithObjectMethod = (key) -> ->
      #   calls[key] =
      #     context: this
      #     arguments: arguments
      #   @key = key
      #   @render hamlc: ''

      class TestController extends Controller
        @after 'afterFilter', only: 'index'
        @before 'beforeFilter', except: ['show', 'update', 'edit', 'delete']

        for key in CRUD
          TestController::[key] = genViewMethod key

        edit: genViewNoRenderMethod 'edit'
        # delete: genViewRenderWithObjectMethod 'delete'

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
global.expectView = (method, req, res) ->
  req = request() unless req?
  res = response() unless res?

  toRespond: (status=200, body) ->
    it "should respond with status #{status}", ->
      ended = false

      runs ->
        @controller[method] req, res.merge send: (s, r) ->
          expect(s).toBe(status)
          expect(r).toBe(body) if body?
          ended = true

      waitsFor progress(-> ended), "Timed out in controller #{method}", 1000
