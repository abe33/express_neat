(function() {
  var CRUD, Controller, Neat, Signal, asArray, bind, render, resolve, viewsFilterArrays, viewsFilterSignals, _,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  resolve = require('path').resolve;

  Neat = require('neat');

  Signal = Neat.require('core/signal');

  render = Neat.require('utils/templates').render;

  _ = Neat.i18n.getHelper();

  CRUD = ['index', 'show', 'edit', 'update', 'create', 'destroy', 'new'];

  bind = function(fn, context) {
    return function() {
      return fn.apply(context, arguments);
    };
  };

  asArray = function(o) {
    if (Array.isArray(o)) {
      return o;
    } else {
      return [o];
    }
  };

  viewsFilterSignals = function() {
    var k, o, _i, _len;
    o = {};
    for (_i = 0, _len = CRUD.length; _i < _len; _i++) {
      k = CRUD[_i];
      o[k] = new Signal;
    }
    return o;
  };

  viewsFilterArrays = function() {
    var k, o, _i, _len;
    o = {};
    for (_i = 0, _len = CRUD.length; _i < _len; _i++) {
      k = CRUD[_i];
      o[k] = [];
    }
    return o;
  };

  Controller = (function() {

    Controller.partialName = function() {
      return this.name.replace('Controller', '').toLowerCase();
    };

    Controller.crud = CRUD;

    Controller.filters = {
      after: viewsFilterArrays(),
      before: viewsFilterArrays()
    };

    Controller.addFilter = function(signal, filter, options) {
      var view, views, _i, _len, _results;
      views = this.crud.concat();
      if (options.only != null) {
        views = views.filter(function(v) {
          return __indexOf.call(asArray(options.only), v) >= 0;
        });
      } else if (options.except != null) {
        views = views.filter(function(v) {
          return __indexOf.call(asArray(options.except), v) < 0;
        });
      }
      _results = [];
      for (_i = 0, _len = views.length; _i < _len; _i++) {
        view = views[_i];
        _results.push(this.filters[signal][view].push(filter));
      }
      return _results;
    };

    Controller.after = function(filter, options) {
      if (options == null) {
        options = {};
      }
      return this.addFilter('after', filter, options);
    };

    Controller.before = function(filter, options) {
      if (options == null) {
        options = {};
      }
      return this.addFilter('before', filter, options);
    };

    Controller.wrap = function(self, method) {
      var fn;
      fn = self[method];
      return function(req, res) {
        self.request = req;
        self.response = res;
        self.currentView = method;
        return self.filters.before[method].dispatch(method, function() {
          return fn.callAsync(self, req, res, function() {
            return Controller.invokeAfterFilters(self, method);
          });
        });
      };
    };

    Controller.invokeAfterFilters = function(self, method, req, res) {
      return self.filters.after[method].dispatch(req, res, function() {
        if (!self.renderWasCalled) {
          return self.render();
        }
      });
    };

    function Controller() {
      var filter, filters, key, signal, view, views, _i, _j, _len, _len1, _ref, _ref1;
      this.filters = {
        after: viewsFilterSignals(),
        before: viewsFilterSignals()
      };
      this.directory = eval('__dirname');
      _ref = Controller.crud;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        this[key] = Controller.wrap(this, key);
      }
      _ref1 = Controller.filters;
      for (signal in _ref1) {
        views = _ref1[signal];
        for (view in views) {
          filters = views[view];
          for (_j = 0, _len1 = filters.length; _j < _len1; _j++) {
            filter = filters[_j];
            this.filters[signal][view].add(this[filter], this);
          }
        }
      }
    }

    Controller.prototype.render = function(options) {
      var engine, name, path, status,
        _this = this;
      status = null;
      path = null;
      name = this.constructor.partialName();
      this.renderWasCalled = true;
      switch (typeof options) {
        case 'string':
          return this.send(200, options);
        case 'object':
          status = options.status || 200;
          engine = this.findEngineFor(options);
          if (engine == null) {
            return this.trapError(new Error("no engine found"));
          }
          path = resolve(this.directory, name, "" + options[engine] + "." + engine);
          break;
        default:
          status = 200;
          path = resolve(this.directory, name, this.currentView);
      }
      return render(path, this, function(err, response) {
        if (err != null) {
          return _this.trapError(err);
        }
        return _this.send(status, response);
      });
    };

    Controller.prototype.trapError = function(error) {
      return this.send(500, 'Error 500');
    };

    Controller.prototype.send = function(status, response) {
      if (!(this.renderWasCalled && this.sendWasCalled)) {
        this.response.send(status, response);
      }
      return this.sendWasCalled = true;
    };

    Controller.prototype.findEngineFor = function(opts) {
      var k, v;
      for (k in opts) {
        v = opts[k];
        if (Neat.config.engines.templates[k] != null) {
          return k;
        }
      }
    };

    Controller.prototype.toString = function() {
      return "[object " + this.constructor.name + "]";
    };

    return Controller;

  })();

  module.exports = Controller;

}).call(this);
