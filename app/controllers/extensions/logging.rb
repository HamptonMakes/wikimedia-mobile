module ControllerExtensions
  module Logging
    def self.included(klass)
      klass.before :logger_output
      
      # DEVELOPMENT
      if Merb.env == "development"
        klass.before :debug_output
        klass.before :clear_cache
      end
    end

    def logger_output
      Merb.logger.info("ReqLogger #{Time.now.to_s} (#{request.language_code}) #{params[:controller]}/#{params[:action]} | #{request.user_agent} | #{request.device.format_name} | #{request.remote_ip} | #{request.referer}")
    end
    
    def debug_output
      Merb.logger.debug("User Agent: " + request.user_agent)
      Merb.logger.debug("Format: " + request.device.format_name.to_s)
      Merb.logger.debug("Language Code: " + request.language_code)
      Merb.logger.debug("Accepts: " + request.accept)
    end

    def clear_cache
      Cache.clear
    end

    
  end
end