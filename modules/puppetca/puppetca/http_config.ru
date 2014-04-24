require 'puppetca/puppetca_api'

map "/puppet/ca" do
  run Proxy::PuppetCaApi
end
