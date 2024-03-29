(function() {
  var Neat, Router, existsSync, findSync, _;

  Neat = require('neat');

  existsSync = require('fs').existsSync;

  findSync = Neat.require('utils/files').findSync;

  _ = Neat.i18n.getHelper();

  Router = (function() {

    function Router(app, controllers) {
      this.app = app;
      this.controllers = controllers != null ? controllers : {};
      this.routesMap = {
        get: {},
        put: {},
        post: {},
        "delete": {}
      };
    }

    Router.prototype.routes = function(fn) {
      return fn.call(this);
    };

    Router.prototype.namespace = function(namespace, fn) {
      this.namespaces || (this.namespaces = ['']);
      this.namespaces.push(namespace);
      fn.call(this);
      this.namespaces.pop();
      if (this.namespaces.empty()) {
        return this.namespaces = null;
      }
    };

    Router.prototype.resource = function(res) {
      var path;
      path = ("" + (this.getPath('')) + "/" + res).replace(/^\//, '');
      this.get("/" + res, {
        to: "" + path + "#index"
      });
      this.post("/" + res, {
        to: "" + path + "#create"
      });
      this.get("/" + res + "/new", {
        to: "" + path + "#new"
      });
      this.get("/" + res + "/:id", {
        to: "" + path + "#show"
      });
      this.put("/" + res + "/:id", {
        to: "" + path + "#update"
      });
      this["delete"]("/" + res + "/:id", {
        to: "" + path + "#delete"
      });
      return this.get("/" + res + "/:id/edit", {
        to: "" + path + "#edit"
      });
    };

    Router.prototype.root = function(options) {
      if (options == null) {
        options = {};
      }
      return this.get('/', options);
    };

    Router.prototype.get = function(path, options) {
      if (options == null) {
        options = {};
      }
      return this.registerRoute('get', this.getPath(path), options);
    };

    Router.prototype.post = function(path, options) {
      if (options == null) {
        options = {};
      }
      return this.registerRoute('post', this.getPath(path), options);
    };

    Router.prototype.put = function(path, options) {
      if (options == null) {
        options = {};
      }
      return this.registerRoute('put', this.getPath(path), options);
    };

    Router.prototype["delete"] = function(path, options) {
      if (options == null) {
        options = {};
      }
      return this.registerRoute('delete', this.getPath(path), options);
    };

    Router.prototype.match = function(path, options) {
      if (options == null) {
        options = {};
      }
      return this.registerRoute(options.via || 'get', this.getPath(path), options);
    };

    Router.prototype.registerRoute = function(method, path, options) {
      var action, controller, data, expressMethod, m, to, _ref, _ref1,
        _this = this;
      if (options == null) {
        options = {};
      }
      expressMethod = function() {};
      data = {};
      if (typeof options === 'function') {
        data.controller = options;
      } else {
        to = options.to;
        if ((to != null) && typeof to === 'string' && this.validateController(to)) {
          _ref = to.split('#'), controller = _ref[0], action = _ref[1];
          if (action == null) {
            m = _('neat.express.controllers.errors.invalid_controller', {
              method: method,
              path: path,
              options: options
            });
            throw new Error(m);
          }
          data.controller = controller;
          data.action = action;
        } else {
          m = _('neat.express.controllers.errors.invalid_controller', {
            method: method,
            path: path,
            options: options
          });
          throw new Error(m);
        }
      }
      this.routesMap[method][path] = data;
      return (_ref1 = this.app) != null ? _ref1[method](path, function(req, res) {
        var controllerClass;
        if (typeof data.controller === 'function') {
          return data.controller(req, res);
        } else {
          controllerClass = _this.requireController(data.controller);
          controller = new controllerClass;
          return controller[data.action](req, res);
        }
      }) : void 0;
    };

    Router.prototype.hasRoute = function(method, path) {
      return this.routesMap[method][path] != null;
    };

    Router.prototype.matchRoute = function(method, path) {
      var k, res, v, _ref;
      _ref = this.routesMap[method];
      for (k in _ref) {
        v = _ref[k];
        res = this.matchPath(k, path);
        if (res != null) {
          return res;
        }
      }
      return void 0;
    };

    Router.prototype.getPath = function(path) {
      if (this.namespaces) {
        path = "" + (this.namespaces.join('/')) + path;
      }
      return path;
    };

    Router.prototype.matchPath = function(pattern, path) {
      var a, b, elA, elB, i, _i, _len;
      a = pattern.split('/');
      b = path.split('/');
      if (a.length !== b.length) {
        return void 0;
      }
      for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
        elA = a[i];
        elB = b[i];
        if (/^:[a-zA-Z0-9_$][a-zA-Z0-9_$]*$/.test(elA)) {
          continue;
        }
        if (elA !== elB) {
          return void 0;
        }
      }
      return pattern;
    };

    Router.prototype.requireController = function(res) {
      var controllers, ext, paths, _ref,
        _this = this;
      _ref = Neat.config.express, paths = _ref.controllersPaths, ext = _ref.controllersExtension;
      if (typeof paths === 'string') {
        paths = [paths];
      }
      paths = paths.map(function(p) {
        return "" + p + "/" + res + "_controller." + ext;
      });
      controllers = paths.filter(function(p) {
        return existsSync(p);
      });
      if (controllers.length === 0) {
        throw new Error(_('neat.express.controllers.errors.missing_controller', {
          controller: res,
          paths: paths
        }));
      }
      return require(controllers.first());
    };

    Router.prototype.validateController = function(controller) {
      return /^(\/*[a-zA-Z0-9_]+(\/[a-zA-Z0-9_]+)*)(\#[a-zA-Z0-9_]+)*$/.test(controller);
    };

    return Router;

  })();

  module.exports = Router;

}).call(this);
