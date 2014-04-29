module Proxy::Chef
  class Plugin < Proxy::Plugin
    http_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
    https_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
  
    plugin :chefproxy, ::Proxy::VERSION if settings.chefproxy
  end
end