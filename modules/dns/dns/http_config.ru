require 'dns/dns_api'

map "/dns" do
  run Proxy::DnsApi
end
