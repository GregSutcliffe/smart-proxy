require 'test_helper'
require 'dhcp/dhcp/dhcp_plugin'

class DnsTest < Test::Unit::TestCase
  def test_omitted_settings_have_default_values
    assert_equal 'isc', Proxy::DhcpPlugin.settings.dhcp_provider
  end
end