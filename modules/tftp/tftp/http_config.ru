require 'tftp/tftp_api'

map "/tftp" do
  run Proxy::TftpApi
end
