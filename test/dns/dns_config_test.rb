require 'test_helper'
require 'dns/dns/dns_plugin'

class DnsConfigTest < Test::Unit::TestCase
  def test_omitted_settings_have_default_values
    assert_equal 'nsupdate', Proxy::DnsPlugin.settings.dns_provider
  end
end