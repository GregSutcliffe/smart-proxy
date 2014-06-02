require 'chef/chef_request'
require 'chef/authentication'

module Proxy::Chef
  class Api < ::Sinatra::Base
    include ::Proxy::Log
    helpers ::Proxy::Helpers

    error Proxy::Error::BadRequest do
      log_halt(400, "Bad request : " + env['sinatra.error'].message )
    end

    error Proxy::Error::Unauthorized do
      log_halt(401, "Unauthorized : " + env['sinatra.error'].message )
    end

    post "/hosts/facts" do
      Proxy::Chef::Authentication.new.authenticated(request) do |content|
        Proxy::Chef::Facts.new.post_facts(content)
      end
    end

    post "/reports" do
      Proxy::Chef::Authentication.new.authenticated(request) do |content|
        Proxy::Chef::Reports.new.post_report(content)
      end
    end
  end
end
