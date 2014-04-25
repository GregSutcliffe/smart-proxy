require "test/unit"
$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.join(File.dirname(__FILE__), '..', 'modules')

logdir = File.join(File.dirname(__FILE__), '..', 'logs')
FileUtils.mkdir_p(logdir) unless File.exists?(logdir)

require 'proxy/proxy'
require 'proxy/settings'
require 'proxy/log'
require 'proxy/util'
require 'proxy/helpers'
require 'proxy/plugin'

require "mocha/setup"
require "rack/test"

Proxy::SETTINGS_PATH = File.expand_path("fixtures/test_settings.yml", File.dirname(__FILE__))
Proxy::SETTINGS = Settings.load_from_file(:settings_path => Proxy::SETTINGS_PATH)
