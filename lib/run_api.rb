class SmartProxy < Sinatra::Base
  post "/run_script" do
    script_url = params[:url]
    begin
      log_halt 500, "Failed script run: Check Log files" unless Proxy::Run.run_script script_url
    rescue => e
      log_halt 500, "Failed script run: #{e}"
    end
  end
end
