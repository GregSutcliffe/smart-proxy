module Proxy::Run
  extend Proxy::Log

  class << self
    def run_script *url
      logger.info "Starting script run: #{url}"

      command = %x[wget -q -O /tmp/script #{url} && chmod +x /tmp/script && /tmp/script]

      unless command =~ /script complete/
        logger.warn command
        return false
      end
      return true
    end
  end
end
