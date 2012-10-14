{resolve} = require 'path'

requireExpress = (resource) -> require "#{__dirname}/express/#{resource}"

Express =
  require: requireExpress
  root: resolve __dirname, '..'

module.exports = Express
