class ::Proxy::PluginNotFound < ::StandardError; end
class ::Proxy::PluginVersionMismatch < ::StandardError; end

class ::Proxy::Dependency
  attr_reader :name, :version

  def initialize(aname, aversion)
    @name = name.to_sym
    @version = version
  end
end

class ::Proxy::Plugins
  @@loaded = [] # {:name, :version, :class}
  @@registered = {} # plugin_name => instance

  def self.plugin_loaded(a_name, a_version, a_class)
    @@loaded += [{:name => a_name, :version => a_version, :class => a_class}]
  end

  def self.register_loaded_plugins
    @@loaded.each { |plugin| eval(plugin[:class]).new.register_plugin }
  end

  def self.register_plugin(plugin_name, instance)
    @@registered[plugin_name.to_sym] = instance
  end

  def self.unregister_plugin(plugin_name)
    @@registered.delete(plugin_name.to_sym)
  end

  def self.find_registered_plugin(plugin_name)
    @@registered[plugin_name.to_sym]
  end

  def self.registered_plugins
    @@registered.values
  end
end

#
# example of plugin DSL
#
# class ExamplePlugin < ::Proxy::Plugin
#  http_rackup_path File.expand_path("http_config.ru", File.expand_path("../", __FILE__)) # note no https rackup path, module will not be available over https
#  requires :foreman_proxy, ">= 1.5.develop"
#  requires :another_plugin, "~> 1.3.0"
#  default_settings :first => 'first', :second => 'second'
#  plugin :example, "1.2.3"
#  before_registration { call_this }
#  after_registration { call_that }
# end
#
class ::Proxy::Plugin
  include ::Proxy::Log

  class << self
    attr_reader :plugin_name, :version, :before_registration_blk, :after_registration_blk, :get_http_rackup_path, :get_https_rackup_path, :plugin_default_settings

    def before_registration(&blk)
      @before_registration_blk = blk
    end

    def after_registration(&blk)
      @after_registration_blk = blk
    end

    def http_rackup_path(path)
      @get_http_rackup_path = path
    end

    def https_rackup_path(path)
      @get_https_rackup_path = path
    end

    def dependencies
      @dependencies ||= []
    end

    def requires(plugin_name, version_spec)
      self.dependencies += [::Proxy::Dependency.new(plugin_name, version_spec)]
    end

    def default_settings(a_hash = {})
      @plugin_default_settings ||= {}
      @plugin_default_settings.merge!(a_hash)
    end

    def settings
      Settings.load_from_file(:defaults => plugin_default_settings)
    end
  end

  def plugin_name
    self.class.plugin_name
  end

  def version
    self.class.version
  end

  def http_rackup
    File.read(self.class.get_http_rackup_path) unless self.class.get_http_rackup_path.nil?
  end

  def https_rackup
    File.read(self.class.get_https_rackup_path) unless self.class.get_https_rackup_path.nil?
  end

  def self.plugin(plugin_name, aversion)
    @plugin_name = plugin_name.to_sym
    @version = aversion
    ::Proxy::Plugins.plugin_loaded(@plugin_name, @version, self.name)
  end

  def register_plugin
    before_registration
    ::Proxy::Plugins.register_plugin(plugin_name, self)
    after_registration
  rescue Exception => e
    logger.error("Couldn't register plugin #{plugin_name}: #{e.message}")
    ::Proxy::Plugins.unregister_plugin(plugin_name)
  end

  def before_registration
    validate_dependencies!(self.class.dependencies)
    self.class.before_registration_blk.call if self.class.before_registration_blk
  end

  def after_registration
    self.class.after_registration_blk.call if self.class.after_registration_blk
  end

  def validate_dependencies!(dependencies)
    dependencies.each do |dep|
      plugin = ::Proxy::Plugins.find_registered_plugin(dep.name)
      raise ::Proxy::PluginNotFound "Plugin '#{dep.name}' required by plugin '#{plugin_name}' could not be found." unless plugin
      unless ::Gem::Dependency.new('', dep.version).match?('', version)
        raise ::Proxy::PluginVersionMismatch "Available version '#{version}' of plugin '#{dep.name}' doesn't match version '#{dep.version}' required by plugin '#{plugin_name}'"
      end
    end
  end
end
