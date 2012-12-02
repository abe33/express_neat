(function() {

  module.exports = function(config) {
    return config.express = {
      controllersPaths: config.paths.map(function(p) {
        return "" + p + "/lib/app/controllers";
      }),
      controllersExtension: 'js'
    };
  };

}).call(this);
