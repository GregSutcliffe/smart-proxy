$LOAD_PATH.unshift File.expand_path("../", __FILE__)

require 'dns/dns_plugin'
require 'dns/dns_api'

module Proxy::DNS
  class Error < RuntimeError; end
  class Collision < RuntimeError; end
  class Record
    include Proxy::Log

    def initialize options = {}
      @server = options[:server] || "localhost"
      @fqdn   = options[:fqdn]
      @ttl    = options[:ttl]    || "86400"
      @type   = options[:type]   || "A"
      @value  = options[:value]

      raise("Must define FQDN or Value") if @fqdn.nil? and @value.nil?
    end
  end
end
