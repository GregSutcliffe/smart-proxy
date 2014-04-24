require "test/unit"
$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.join(File.dirname(__FILE__), '..', 'modules')

logdir = File.join(File.dirname(__FILE__), '..', 'logs')
FileUtils.mkdir_p(logdir) unless File.exists?(logdir)

require 'proxy/proxy'
require 'testing_settings'
require 'proxy/log'
require 'proxy/util'
require 'proxy/helpers'
require 'proxy/plugin'

require "mocha/setup"
require "rack/test"
