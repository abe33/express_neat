(function() {
  var Express, Neat, aliases, describe, environment, error, express, fs, green, info, lock, lockPath, locked, puts, red, server, trap, unlock, usages, _, _ref, _ref1,
    __slice = [].slice;

  fs = require('fs');

  Neat = require('neat');

  express = require('express');

  _ref = Neat.require('utils/logs'), error = _ref.error, green = _ref.green, info = _ref.info, puts = _ref.puts, red = _ref.red;

  _ref1 = Neat.require('utils/commands'), aliases = _ref1.aliases, describe = _ref1.describe, environment = _ref1.environment, usages = _ref1.usages;

  _ = Neat.i18n.getHelper();

  Express = require('..');

  lockPath = "" + Neat.root + "/.serverlock";

  lock = function() {
    return fs.writeFileSync(lockPath);
  };

  locked = function() {
    return fs.existsSync(lockPath);
  };

  unlock = function() {
    return fs.unlinkSync(lockPath);
  };

  trap = function() {
    var signal, signals, _i, _len, _results;
    signals = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = signals.length; _i < _len; _i++) {
      signal = signals[_i];
      _results.push(process.on(signal, function() {
        var m;
        m = red(_('neat.express.errors.server_terminated', {
          signal: signal
        }));
        puts(m, 5);
        unlock();
        return process.exit(1);
      }));
    }
    return _results;
  };

  server = function(pr) {
    var cmd;
    if (pr == null) {
      return error("No program provided to server");
    }
    return aliases('server', 's', describe('Runs a server using express.js', cmd = function() {
      var app, args, callback, port, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      console.log("server run");
      if (locked()) {
        return error(red(_('neat.express.errors.server_running')));
      }
      lock();
      port = Neat.config.server.port;
      app = express();
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      trap('SIGTERM', 'SIGKILL', 'SIGINT');
      process.on('uncaughtException', function(e) {
        console.log(e.message.red);
        console.log(e.stack);
        unlock();
        return process.exit(1);
      });
      Express.loadRoutes(app);
      app.listen(port);
      return info(green(_('neat.express.server_started', {
        port: port
      })));
    }));
  };

  module.exports = {
    server: server
  };

}).call(this);
