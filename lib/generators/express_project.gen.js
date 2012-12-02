(function() {
  var Neat, basename, describe, ensureSync, error, extname, green, hashArguments, missing, namespace, notOutsideNeat, project, puts, render, resolve, touchSync, usages, warn, _, _ref, _ref1, _ref2, _ref3,
    __slice = [].slice;

  _ref = require('path'), resolve = _ref.resolve, basename = _ref.basename, extname = _ref.extname;

  Neat = require('neat');

  _ref1 = Neat.require("utils/logs"), puts = _ref1.puts, error = _ref1.error, warn = _ref1.warn, missing = _ref1.missing, green = _ref1.green, notOutsideNeat = _ref1.notOutsideNeat;

  _ref2 = Neat.require("utils/files"), ensureSync = _ref2.ensureSync, touchSync = _ref2.touchSync;

  namespace = Neat.require("utils/exports").namespace;

  render = Neat.require("utils/templates").renderSync;

  _ref3 = Neat.require("utils/commands"), usages = _ref3.usages, describe = _ref3.describe, hashArguments = _ref3.hashArguments;

  _ = Neat.i18n.getHelper();

  usages('neat generate express:project', describe(_('neat.commands.generate.express_project.description'), project = function() {
    var a, args, b, callback, context, d, dirs, e, files, generator, t, tplpath, _i, _j, _k, _len, _len1, _ref4, _results;
    generator = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
    if (Neat.root == null) {
      throw new Error(notOutsideNeat(process.argv.join(" ")));
    }
    if (args.length === 0 && typeof callback !== 'function') {
      args.push(callback);
    }
    tplpath = resolve(__dirname, "express");
    context = args.empty() ? {} : hashArguments(args);
    dirs = ["" + Neat.root + "/assets", "" + Neat.root + "/src/app", "" + Neat.root + "/src/app/controllers", "" + Neat.root + "/src/app/models", "" + Neat.root + "/templates/views"];
    files = [["" + Neat.root + "/assets/.gitkeep"], ["" + Neat.root + "/src/app/controllers/.gitkeep"], ["" + Neat.root + "/src/app/models/.gitkeep"], ["" + Neat.root + "/templates/views/.gitkeep"], ["" + Neat.root + "/src/config/routes.coffee", 'routes']];
    t = function(a, b) {
      touchSync(a, (b ? render(resolve(tplpath, b)) : ''), context);
      return puts(green(_('neat.commands.generate.project.generation_done', {
        path: a
      })), 1);
    };
    e = function(d) {
      ensureSync(d);
      return puts(green(_('neat.commands.generate.project.generation_done', {
        path: d
      })), 1);
    };
    try {
      for (_j = 0, _len = dirs.length; _j < _len; _j++) {
        d = dirs[_j];
        e(d);
      }
      _results = [];
      for (_k = 0, _len1 = files.length; _k < _len1; _k++) {
        _ref4 = files[_k], a = _ref4[0], b = _ref4[1];
        _results.push(t(a, b));
      }
      return _results;
    } catch (e) {
      e.message = _('neat.commands.generate.express_project.generation_failed', {
        message: e.message
      });
      throw e;
      return typeof callback === "function" ? callback() : void 0;
    }
  }));

  module.exports = namespace('express', {
    project: project
  });

}).call(this);
