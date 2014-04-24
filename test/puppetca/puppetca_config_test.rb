require 'test_helper'
require 'puppetca/puppetca/puppetca_plugin'

class PuppetCAConfigTest < Test::Unit::TestCase
  def test_omitted_settings_have_default_values
    assert_equal '/var/lib/puppet/ssl', Proxy::PuppetCAPlugin.settings.ssldir
    assert_equal '/etc/puppet', Proxy::PuppetCAPlugin.settings.puppetdir
  end
end