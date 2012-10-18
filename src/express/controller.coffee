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
    bound = bind fn, self
    return (req, res) ->
      self.request = req
      self.response = res
      self.currentView = method
      self.filters.before[method].dispatch method, ->
        if self.filters.before[method].isAsync fn
          bound.call null, req, res, ->
            Controller.invokeAfterFilters self, method
        else
          bound.call null, req, res
          Controller.invokeAfterFilters self, method, req, res

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
    unless options?
      name = @constructor.partialName()
      path = resolve @directory, @constructor.partialName(), @currentView
      render path, this, (err, response) =>
        throw err if err?
        @sendResponse response

    else if typeof options is 'string'
      @sendResponse options

  sendResponse: (response) ->
    @response.send response unless @renderWasCalled
    @renderWasCalled = true

  toString: -> "[object #{@constructor.name}]"

module.exports = Controller
