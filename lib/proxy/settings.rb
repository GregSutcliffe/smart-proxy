require "checks"
require "yaml"
require "ostruct"
require "pathname"

#require 'proxy/puppet/default_puppet_settings'

class Settings < OpenStruct
  SETTINGS_PATH = Pathname.new(__FILE__).join("..", "..","..","config","settings.yml")
#  DEFAULTS = [Proxy::DNS::DefaultSettings::DEFAULTS].inject({}) do |all, current| #, Proxy::Puppet::DefaultSettings::DEFAULTS
#    all.merge!(current)
#  end

  def self.load_from_file(opts = {})
    settings_path = opts[:settings_path] || SETTINGS_PATH
    defaults = opts[:defaults] || {}

    settings = YAML.load(File.read(settings_path))
    if PLATFORM =~ /mingw/
      settings.delete :puppetca if settings.has_key? :puppetca
      settings.delete :puppet   if settings.has_key? :puppet
      settings[:x86_64] = File.exist?('c:\windows\sysnative\cmd.exe')
    end
    load(settings.merge(defaults))
  end

  def self.load(ahash)
    Settings.new(ahash)
  end

  def method_missing(symbol, *args)
    nil
  end
end
