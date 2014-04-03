APP_ROOT = "#{File.dirname(__FILE__)}/.."

require 'sinatra'
require "fileutils"
require "pathname"
require "checks"

module Proxy
  require 'proxy/settings'
  require 'proxy/module_config'
  require 'proxy/log'
  require 'proxy/util'
  require 'proxy/version'

  ::SETTINGS = Settings.load_from_file

  ::Sinatra::Base.set :run, false
  ::Sinatra::Base.set :root, APP_ROOT
  ::Sinatra::Base.set :views, APP_ROOT + '/views'
  ::Sinatra::Base.set :public_folder, APP_ROOT + '/public'
  ::Sinatra::Base.set :logging, true
  ::Sinatra::Base.set :env, :production
#  ::Sinatra::Base.use ::Rack::CommonLogger, logger

  require 'root/root'
  require 'dns/dns'

  def self.version
    {:version => VERSION}
  end

  MODULES = %w{dns dhcp tftp puppetca puppet bmc chefproxy}
  def self.features
    MODULES.collect{|mod| mod if SETTINGS.send mod}.compact
  end
end
