module Proxy::Log
  require 'logger'

  @@logger = nil

  def logger
    return @@logger if @@logger

    # We keep the last 6 10MB log files
    @@logger = Logger.new(::Proxy::SETTINGS.log_file, 6, 1024*1024*10)
    @@logger.level = Logger.const_get(::Proxy::SETTINGS.log_level.upcase) if ::Proxy::SETTINGS.log_level
    @@logger
  end
end
