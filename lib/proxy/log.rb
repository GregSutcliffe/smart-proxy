require 'logger'

module Proxy
  module Log
    @@logger = nil

    def logger
      return @@logger if @@logger

      # We keep the last 6 10MB log files
      @@logger = Logger.new(::Proxy::SETTINGS.log_file, 6, 1024*1024*10)
      @@logger.level = Logger.const_get(::Proxy::SETTINGS.log_level.upcase)
      @@logger
    end
  end

  class LoggerMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      logger = ::Logger.new(::Proxy::SETTINGS.log_file, 6, 1024*1024*10)
      logger.level = ::Logger.const_get(::Proxy::SETTINGS.log_level.upcase)

      env['rack.logger'] = logger
      @app.call(env)
    end
  end
end
