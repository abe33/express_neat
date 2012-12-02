(function() {
  var Express, Neat, aliases, describe, environment, error, render, routes, usages, _ref,
    __slice = [].slice;

  Neat = require('neat');

  Express = require('..');

  error = Neat.require('utils/logs').error;

  _ref = Neat.require('utils/commands'), aliases = _ref.aliases, describe = _ref.describe, environment = _ref.environment, usages = _ref.usages;

  render = Neat.require('utils/templates').render;

  routes = function(pr) {
    var cmd;
    if (pr == null) {
      return error("No program provided to routes");
    }
    return aliases('routes', environment('production', describe('TODO: Description goes here', cmd = function() {
      var args, callback, controller, controllers, list, map, maxPathLength, method, o, path, router, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      router = Express.loadRoutes();
      map = router.routesMap;
      list = [];
      maxPathLength = 0;
      for (method in map) {
        controllers = map[method];
        for (path in controllers) {
          controller = controllers[path];
          o = {
            method: method,
            path: path
          };
          maxPathLength = Math.max(maxPathLength, path.length);
          if (typeof controller.controller === 'function') {
            o.controller = '[Function]';
          } else {
            o.controller = "" + controller.controller + "#" + controller.action;
          }
          list.push(o);
        }
      }
      list.sort(function(a, b) {
        if (a.path > b.path) {
          return 1;
        } else if (b.path > a.path) {
          return -1;
        } else {
          return 0;
        }
      });
      return render(__filename, {
        list: list,
        maxPathLength: maxPathLength
      }, function(err, res) {
        if (err != null) {
          throw err;
        }
        console.log(res);
        return typeof callback === "function" ? callback() : void 0;
      });
    })));
  };

  module.exports = {
    routes: routes
  };

}).call(this);
