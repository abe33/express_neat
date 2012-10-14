Neat = require 'neat'
{resolve} = require 'path'
Router = require '../../../lib/express/router'
baz = require '../../fixtures/express/controllers/baz_controller'
bar = require '../../fixtures/express/controllers/foo/bar_controller'

global.withRouter = (block) ->
  describe 'Router', ->
    beforeEach ->
      path = resolve __dirname, "../../fixtures/express/controllers"
      calls = {}

      getRequest = (method, path, options) -> {}
      getResult = () -> send: (content) ->

      Neat.config ||= {}
      Neat.config.express =
        controllersPaths: path
        controllersExtension: 'coffee'

      insert = (method, path, controller) ->
        calls[method] ||= {}
        calls[method][path] = [path, controller]

      @controllerClasses = {baz, bar}
      @anonymousCalls = 0
      self = this

      @calls = calls
      @app =
        get: (path, controller) -> insert 'get', path, controller
        put: (path, controller) -> insert 'put', path, controller
        post: (path, controller) -> insert 'post', path, controller
        delete: (path, controller) -> insert 'delete', path, controller

      @router = new Router @app
      @router.routes ->
        @root to: 'baz#index'
        @match '/baz', to: 'baz#index'
        @post '/baz/foo', to: 'baz#foo'
        @put '/oof/:id', -> self.anonymousCalls++
        @delete '/oof/:id', -> self.anonymousCalls++

        expect(-> @get 'foo').toThrow()
        expect(-> @put 'foo').toThrow()
        expect(-> @delete 'foo').toThrow()
        expect(-> @post 'foo').toThrow()
        expect(-> @match 'foo').toThrow()
        expect(-> @root()).toThrow()

        @namespace 'foo', ->
          @resource 'bar'

      @trigger = (method, path, options) ->
        @calls[method][path][1](
          getRequest(method, path, options),
          getResult()
        )

      @get = (path, options) -> @trigger 'get', path, options
      @post = (path, options) -> @trigger 'post', path, options
      @put = (path, options) -> @trigger 'put', path, options
      @delete = (path, options) -> @trigger 'delete', path, options

    block.call this

global.expectRoute = (method, route) ->
  [route, method] = [method, 'get'] unless route?
  toValidate: (path) ->
    it "sould validate the path #{route}", ->
      expect(@router.validateController route).toBeTruthy()
  toExists: ->
    it "sould have registered the route #{method.toUpperCase()} #{route}", ->
      expect(@router.hasRoute method, route).toBeTruthy()
      expect(@calls[method][route]).toBeDefined()

  toMatch: (path) ->
    describe "with the path #{method.toUpperCase()} #{route}", ->
      it "sould match the route #{method.toUpperCase()} #{path}", ->
        expect(@router.matchRoute method, route).toBe(path)

  toHaveRegistered: (controller) ->
    describe "with the path #{method.toUpperCase()} #{route}", ->
      it "should have registered the controller #{controller}", ->
        data = @router.routesMap[method][route]
        expect("#{data.controller}##{data.action}").toBe(controller)

  not:
    toExists: ->
      m = method.toUpperCase()
      it "souldn't have registered the route #{m} #{route}", ->
        expect(@router.hasRoute method, route).toBeFalsy()

    toMatch: () ->
      describe "with the path #{method.toUpperCase()} #{route}", ->
        it "souldn't match any route", ->
          expect(@router.matchRoute method, route).toBeUndefined()

    toValidate: (path) ->
      it "sould validate the path #{route}", ->
        expect(@router.validateController route).toBeFalsy()
