
module.exports = (config) ->
  config.express =
    controllersPaths: config.paths.map (p) -> "#{p}/lib/app/controllers"
    controllersExtension: 'js'
