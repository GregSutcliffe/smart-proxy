class ::Proxy::RootPlugin < ::Proxy::Plugin
  plugin :foreman_proxy, ::Proxy::VERSION
  http_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
  https_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
end