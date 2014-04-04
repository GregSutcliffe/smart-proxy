include ::Proxy::Log
begin
  require "facter"
  require 'facts_module_config'
  require 'facts_api'
rescue LoadError
  logger.info "Facter was not found, Facts API disabled"
end

