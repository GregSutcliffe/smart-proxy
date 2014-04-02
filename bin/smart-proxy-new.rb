#!/usr/bin/env ruby

$LOAD_PATH.unshift *Dir[File.expand_path("../../lib", __FILE__), File.expand_path("../../modules", __FILE__)]

require 'bundler'
require 'json'

require 'smart_proxy_new'

Bundler.require

if SETTINGS.daemon
  pid_path = File.dirname(SETTINGS.daemon_pid)
  FileUtils.mkdir_p(pid_path) unless File.exists?(pid_path)
end

app = Rack::Builder.new do
  configs = ObjectSpace.each_object(::Class).select {|klass| klass < ::Proxy::ModuleConfig}
  configs.each {|c| instance_eval(File.read(c.http_rackup_path))}
end

#app1 = Rack::Builder.new do
#  configs = ObjectSpace.each_object(::Class).select {|klass| klass < ::Proxy::ModuleConfig}
#  configs.each {|c| instance_eval(File.read(c.rackup_config_path))}
#end

s1 = Rack::Server.new(
  :app => app, 
  :server => :webrick,
  :Port => SETTINGS.port,
  :daemonize => SETTINGS.daemon,
  :pid => SETTINGS.daemon ? pid_path : nil)

#s2 =   Rack::Server.new(
#    :app => app1, 
#    :server => :webrick,
#    :Port => 1235,
#    :daemonize => false,
#    :pid => nil)

t1 = Thread.new { s1.start }  
#t2 = Thread.new { s2.start }

#trap(:INT) do
#  s1.shutdown
#  s2.shutdown
#end

t1.join

Process.daemon
