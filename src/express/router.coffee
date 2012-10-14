Neat = require 'neat'
{existsSync} = require 'fs'
{findSync} = Neat.require 'utils/files'
_ = Neat.i18n.getHelper()

class Router
  constructor: (@app, @controllers={}) ->
    @routes_ =
      get: {}
      put: {}
      post: {}
      delete: {}

  routes: (fn) -> fn.call this

  ##### Helpers

  namespace: (namespace, fn) ->
    @namespaces ||= ['']
    @namespaces.push namespace
    fn.call this
    @namespaces.pop()
    @namespaces = null if @namespaces.empty()

  resource: (res) ->
    path = "#{@getPath ''}/#{res}".replace /^\//, ''

    @get "/#{res}", to: "#{path}#index"
    @post "/#{res}", to: "#{path}#create"
    @get "/#{res}/new", to: "#{path}#new"
    @get "/#{res}/:id", to: "#{path}#show"
    @put "/#{res}/:id", to: "#{path}#update"
    @delete "/#{res}/:id", to: "#{path}#delete"
    @get "/#{res}/:id/edit", to: "#{path}#edit"

  root: (options={}) ->
    @get '/', options
  get: (path, options={}) ->
    @registerRoute 'get', @getPath(path), options
  post: (path, options={}) ->
    @registerRoute 'post', @getPath(path), options
  put: (path, options={}) ->
    @registerRoute 'put', @getPath(path), options
  delete: (path, options={}) ->
    @registerRoute 'delete', @getPath(path), options
  match: (path, options={}) ->
    @registerRoute (options.via || 'get'), @getPath(path), options

  ##### Routes

  registerRoute: (method, path, options={}) ->
    expressMethod = ->

    data = {}

    if typeof options is 'function'
      data.controller = options
    else
      {to} = options
      if to? and typeof to is 'string' and @validateController to
        [controller, action] = to.split '#'
        unless action?
          m = _ 'neat.express.controllers.errors.invalid_controller',
                 {method, path, options}
          throw new Error m

        data.controller = controller
        data.action = action
      else
        m = _ 'neat.express.controllers.errors.invalid_controller',
               {method, path, options}
        throw new Error m

    @routes_[method][path] = data
    @app[method] path, (req, res)=>
      if typeof data.controller is 'function'
        data.controller(req, res)
      else
        controllerClass = @requireController data.controller
        controller = new controllerClass
        controller[data.action](req, res)

  hasRoute: (method, path) -> @routes_[method][path]?

  matchRoute: (method, path) ->
    for k,v of @routes_[method]
      res = @matchPath k, path
      return res if res?
    undefined

  ##### Paths

  getPath: (path) ->
    path = "#{@namespaces.join '/'}#{path}" if @namespaces
    path

  matchPath: (pattern, path) ->
    a = pattern.split('/')
    b = path.split('/')
    return undefined unless a.length is b.length
    for elA,i in a
      elB = b[i]
      continue if /^:[a-zA-Z0-9_$][a-zA-Z0-9_$]*$/.test elA
      return undefined if elA isnt elB
    pattern

  ##### Controllers

  requireController: (res) ->
    {controllersPaths:paths, controllersExtension:ext} = Neat.config.express
    paths = [paths] if typeof paths is 'string'
    paths = paths.map (p)=> "#{p}/#{res}_controller.#{ext}"
    controllers = paths.filter (p) -> existsSync p

    if controllers.length is 0
      throw new Error _ 'neat.express.controllers.errors.missing_controller',
                        controller: res
                        paths: paths

    require controllers.first()

  validateController: (controller) ->
    /^(\/*[a-zA-Z0-9_]+(\/[a-zA-Z0-9_]+)*)(\#[a-zA-Z0-9_]+)*$/.test controller

module.exports = Router
