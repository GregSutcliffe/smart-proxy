require 'test_helper'
require 'puppet/initializer'

class PuppetInitializerTest < Test::Unit::TestCase
  def test_config_returns_puppet_conf
    Proxy::Puppet::Plugin.settings.expects(:puppet_conf).returns('/foo/puppet.conf')
    assert_equal '/foo/puppet.conf', Proxy::Puppet::Initializer.config
  end

  def test_config_returns_puppetdir
    Proxy::Puppet::Plugin.settings.stubs(:puppet_conf).returns(nil)
    Proxy::Puppet::Plugin.settings.expects(:puppetdir).returns('/foo')
    assert_equal '/foo/puppet.conf', Proxy::Puppet::Initializer.config
  end

  def test_config_returns_default
    Proxy::Puppet::Plugin.settings.stubs(:puppet_conf).returns(nil)
    Proxy::Puppet::Plugin.settings.expects(:puppetdir).returns(nil)
    assert_equal '/etc/puppet/puppet.conf', Proxy::Puppet::Initializer.config
  end
end
