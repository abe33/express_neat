(function() {
  var Express, Neat, Router, requireExpress, resolve;

  resolve = require('path').resolve;

  Neat = require('neat');

  requireExpress = function(resource) {
    return require("" + __dirname + "/express/" + resource);
  };

  Router = requireExpress('router');

  Express = {
    require: requireExpress,
    root: resolve(__dirname, '..'),
    loadRoutes: function(app) {
      var router, routes;
      router = new Router(app);
      routes = require("" + Neat.root + "/lib/config/routes");
      router.routes(routes);
      return router;
    }
  };

  module.exports = Express;

}).call(this);
