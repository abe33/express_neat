{resolve} = require 'path'
Neat = require 'neat'
Signal = Neat.require 'core/signal'
{render} = Neat.require 'utils/templates'
_ = Neat.i18n.getHelper()

#### Utilities
CRUD = ['index', 'show', 'edit', 'update', 'create', 'destroy', 'new']
bind = (fn, context) -> -> fn.apply context, arguments
asArray = (o) -> if Array.isArray o then o else [o]
viewsFilterSignals = -> o = {}; o[k] = new Signal for k in CRUD; o
viewsFilterArrays = -> o = {}; o[k] = [] for k in CRUD; o

## Controller
class Controller
  #### Class Members
  @partialName: -> @name.replace('Controller','').toLowerCase()
  @crud: CRUD
  @filters =
    after: viewsFilterArrays()
    before: viewsFilterArrays()

  @addFilter: (signal, filter, options) ->
    views = @crud.concat()
    if options.only?
      views = views.filter (v) -> v in asArray options.only
    else if options.except?
      views = views.filter (v) -> v not in asArray options.except

    for view in views
      @filters[signal][view].push filter

  @after: (filter, options={}) -> @addFilter 'after', filter, options
  @before: (filter, options={}) -> @addFilter 'before', filter, options

  @wrap: (self, method) ->
    fn = self[method]
    return (req, res) ->
      self.request = req
      self.response = res
      self.currentView = method
      self.filters.before[method].dispatch method, ->
        fn.callAsync self, req, res, ->
          Controller.invokeAfterFilters self, method

  @invokeAfterFilters: (self, method, req, res) ->
    self.filters.after[method].dispatch req, res, ->
      unless self.renderWasCalled then self.render()

  #### Instance Members
  constructor: ->
    @filters =
      after: viewsFilterSignals()
      before: viewsFilterSignals()
    @directory = eval '__dirname'

    for key in Controller.crud
      @[key] = Controller.wrap this, key

    for signal, views of Controller.filters
      for view, filters of views
        for filter in filters
          @filters[signal][view].add @[filter], this

  render: (options) ->
    status = null
    path = null
    name = @constructor.partialName()
    @renderWasCalled = true

    switch typeof options
      when 'string' then return @send 200, options
      when 'object'
        status = options.status || 200
        engine = @findEngineFor options
        return @trapError new Error "no engine found" unless engine?
        path = resolve @directory, name, "#{options[engine]}.#{engine}"
      else
        status = 200
        path = resolve @directory, name, @currentView

    render path, this, (err, response) =>
      return @trapError err if err?
      @send status, response

  trapError: (error) ->
    @send 500, 'Error 500'

  send: (status, response) ->
    @response.send status, response unless @renderWasCalled and @sendWasCalled
    @sendWasCalled = true

  findEngineFor: (opts) ->
    return k for k,v of opts when Neat.config.engines.templates[k]?

  toString: -> "[object #{@constructor.name}]"

module.exports = Controller
