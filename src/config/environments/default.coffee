module.exports = (config) ->
  # `config.verbosity` limits the output to logs with a level
  # greater than or equal to the verbosity value.
  #
  # The following levels are defined:
  #
  #   0. debug
  #   1. info
  #   2. warn
  #   3. error
  #   4. fatal
  #
  # config.verbosity = 0

  # `config.defaultLoggingEngine` allow to setup a different
  # logging engine at start.
  #
  # config.defaultLoggingEngine = 'console'

  config.server =
    host: 'localhost'
    port: '3000'
