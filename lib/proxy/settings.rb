require "checks"
require "yaml"
require "ostruct"
require "pathname"

class Settings < OpenStruct
  def self.load_from_file(opts = {})
    settings_path = opts[:settings_path] || ::Proxy::SETTINGS_PATH
    defaults = opts[:defaults] || {}
    load(YAML.load(File.read(settings_path)), defaults)
  end

  def self.load(settings, defaults)
    if PLATFORM =~ /mingw/
      settings.delete :puppetca if settings.has_key? :puppetca
      settings.delete :puppet   if settings.has_key? :puppet
      settings[:x86_64] = File.exist?('c:\windows\sysnative\cmd.exe')
    end
    Settings.new(defaults.merge(settings))
  end

  def method_missing(symbol, *args)
    nil
  end
end
