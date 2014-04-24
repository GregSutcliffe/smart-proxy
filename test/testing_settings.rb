require "proxy/settings"
Proxy::SETTINGS_PATH = File.expand_path("fixtures/test_settings.yml", File.dirname(__FILE__))
Proxy::SETTINGS = Settings.load_from_file(:settings_path => Proxy::SETTINGS_PATH)
