class Proxy::RootConfig < ::Proxy::ModuleConfig
  def self.http_rackup_path
    File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
  end

  def self.https_rackup_path
    File.expand_path("http_config.ru", File.expand_path("../", __FILE__))
  end
end