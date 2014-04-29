require 'test_helper'
require 'dns/dns_plugin'

class DnsConfigTest < Test::Unit::TestCase
  def test_omitted_settings_have_default_values
    assert_equal 'nsupdate', Proxy::Dns::Plugin.settings.dns_provider
  end
end