class Proxy::DnsApi < ::Sinatra::Base
  require 'proxy/helpers'
  include ::Proxy::Log
  include ::Proxy::Helpers

  def dns_setup(opts)
    raise "Smart Proxy is not configured to support DNS" unless SETTINGS.dns
    case SETTINGS.dns_provider
    when "dnscmd"
      require 'dns/providers/dnscmd'
      @server = Proxy::DNS::Dnscmd.new(opts.merge(
        :server => SETTINGS.dns_server,
        :ttl => SETTINGS.dns_ttl
      ))
    when "nsupdate"
      require 'dns/providers/nsupdate'
      @server = Proxy::DNS::Nsupdate.new(opts.merge(
        :server => SETTINGS.dns_server,
        :ttl => SETTINGS.dns_ttl
      ))
    when "nsupdate_gss"
      require 'dns/providers/nsupdate_gss'
      @server = Proxy::DNS::NsupdateGSS.new(opts.merge(
        :server => SETTINGS.dns_server,
        :ttl => SETTINGS.dns_ttl,
        :tsig_keytab => SETTINGS.dns_tsig_keytab,
        :tsig_principal => SETTINGS.dns_tsig_principal
      ))
    when "virsh"
      require 'dns/providers/virsh'
      @server = Proxy::DNS::Virsh.new(opts.merge(
        :virsh_network => SETTINGS.virsh_network
      ))
    else
      log_halt 400, "Unrecognized or missing DNS provider: #{SETTINGS.dns_provider || "MISSING"}"
    end
  rescue => e
    log_halt 400, e
  end

  post "/" do
    fqdn  = params[:fqdn]
    value = params[:value]
    type  = params[:type]
    begin
      dns_setup({:fqdn => fqdn, :value => value, :type => type})
      @server.create
    rescue Proxy::DNS::Collision => e
      log_halt 409, e
    rescue Exception => e
      log_halt 400, e
    end
  end

  delete "/:value" do
    case params[:value]
    when /\.(in-addr|ip6)\.arpa$/
      type = "PTR"
      value = params[:value]
    else
      fqdn = params[:value]
    end
    begin
      dns_setup({:fqdn => fqdn, :value => value, :type => type})
      @server.remove
    rescue => e
      log_halt 400, e
    end
  end
end
