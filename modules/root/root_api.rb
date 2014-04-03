class Proxy::RootApi < Sinatra::Base
  require 'proxy/helpers'
  include ::Proxy::Helpers

  get "/features" do
    begin
      @features = Proxy.features.sort
      if request.accept? 'application/json'
        content_type :json
        @features.to_json
      else
        erb :"features/index"
      end
    rescue => e
      log_halt 400, e
    end
  end

  get "/version" do
    begin
      {:version => Proxy::VERSION}.to_json
    rescue => e
      log_halt 400, e
    end
  end
end
