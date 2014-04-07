APP_ROOT = "#{File.dirname(__FILE__)}/.."

require 'sinatra'
require 'fileutils'
require 'pathname'
require 'checks'
require 'webrick/https'

module Proxy
  require 'proxy/settings'
  require 'proxy/module_config'
  require 'proxy/log'
  require 'proxy/util'
  require 'proxy/version'
  require 'proxy/helpers'

  ::SETTINGS = Settings.load_from_file

  ::Sinatra::Base.set :run, false
  ::Sinatra::Base.set :root, APP_ROOT
  ::Sinatra::Base.set :views, APP_ROOT + '/views'
  ::Sinatra::Base.set :public_folder, APP_ROOT + '/public'
  ::Sinatra::Base.set :logging, true
  ::Sinatra::Base.set :env, :production
#  ::Sinatra::Base.use ::Rack::CommonLogger, logger

  require 'root/root'
  require 'facts/facts'
  require 'dns/dns'
  require 'dhcp/dhcp'
  require 'puppetca/puppetca'

  def self.version
    {:version => VERSION}
  end

  MODULES = %w{dns dhcp tftp puppetca puppet bmc chefproxy}
  def self.features
    MODULES.collect{|mod| mod if SETTINGS.send mod}.compact
  end

  class Launcher
    include ::Proxy::Log

    def pid_path
      SETTINGS.daemon_pid
    end

    def create_pid_dir
      if SETTINGS.daemon
        FileUtils.mkdir_p(File.dirname(pid_path)) unless File.exists?(pid_path)
      end
    end

    def http_app
      app = Rack::Builder.new do
        configs = ObjectSpace.each_object(::Class).select {|klass| klass < ::Proxy::ModuleConfig}
        configs.each {|c| instance_eval(File.read(c.http_rackup_path))}
      end

      Rack::Server.new(
        :app => app, 
        :server => :webrick,
        :Port => SETTINGS.http_port,
        :daemonize => false,
        :pid => SETTINGS.daemon ? pid_path : nil)
    end

    def https_app
      unless SETTINGS.ssl_private_key and SETTINGS.ssl_certificate and SETTINGS.ssl_ca_file
        logger.info "Missing SSL setup, will not be listening on https port"
      else
        begin
          app = Rack::Builder.new do
            configs = ObjectSpace.each_object(::Class).select {|klass| klass < ::Proxy::ModuleConfig}
            configs.each {|c| instance_eval(File.read(c.https_rackup_path))}
          end

          Rack::Server.new(
            :app => app,
            :server => :webrick,
            :Port => SETTINGS.https_port,
            :SSLEnable => true,
            :SSLVerifyClient => OpenSSL::SSL::VERIFY_PEER,
            :SSLPrivateKey => OpenSSL::PKey::RSA.new(File.read(SETTINGS.ssl_private_key)),
            :SSLCertificate => OpenSSL::X509::Certificate.new(File.read(SETTINGS.ssl_certificate)),
            :SSLCACertificateFile => SETTINGS.ssl_ca_file,
            :daemonize => false,
            :pid => nil)
        rescue => e
          logger.error "Unable to access the SSL keys. Are the values correct in settings.yml and do permissions allow reading?: #{e}"
        end
      end

    end

    def self.launch
      launcher = Launcher.new

      launcher.create_pid_dir
      http_app = launcher.http_app
      https_app = launcher.https_app

      t1 = Thread.new { http_app.start }  
      t2 = Thread.new { https_app.start } unless https_app.nil?

      trap(:INT) do
        http_app.shutdown
        https_app.shutdown unless https_app.nil?
      end

      t2.join

      Process.daemon if SETTINGS.daemon
    end
  end
end
