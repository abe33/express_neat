
requireExpress = (resource) -> require "#{__dirname}/express/#{resource}"

Express =
  require: requireExpress

module.exports = Express
