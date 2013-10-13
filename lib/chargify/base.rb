module Chargify
  class Base
    include HTTParty

    parser Chargify::Parser
    headers 'Content-Type' => 'application/json'
    headers 'User-Agent' => 'Chargify Ruby Client'

    class << self

      def api_request(type, path, options={}, api_version = 1)
        if api_version == 2
          self.base_uri('https://api.chargify.com/api/v2')
          options[:basic_auth] = {:username => Chargify::Config.direct_api_id, :password => Chargify::Config.direct_api_password}
        else
          self.base_uri("https://#{Chargify::Config.subdomain}.chargify.com")
          options[:basic_auth] = {:username => Chargify::Config.api_key, :password => 'x'}
        end

        # This is to allow bang methods
        raise_errors = options.delete(:raise_errors)
        
        # Build options hash for HTTParty
        options[:body] = options[:body].to_json if options[:body]
        Chargify::Config.logger.debug("[CHARGIFY] Sending #{self.base_uri}#{path} a payload of #{options[:body]}") if Chargify::Config.debug

        begin
          response = self.send(type.to_s, path, options)
        rescue SocketError
          raise(Chargify::Error::ConnectionFailed.new, "Failed to connect to payment gateway.")
        end

        response_code = response.code.to_i
        if response_code != 200
          if api_version == 1
            error_message = response.body
          else
            error_message = response['result']['errors'].to_s
          end
        end

        case response_code
        when 401
          raise(Chargify::Error::AccessDenied.new(response), error_message)
        when 403
          raise(Chargify::Error::Forbidden.new(response), error_message)
        when 422
          raise(Chargify::Error::BadRequest.new(response), error_message)
        when 404
          raise(Chargify::Error::NotFound.new(response), error_message)
        when 500
          raise(Chargify::Error::ServerError.new(response), error_message)
        when 501
          raise(Chargify::Error::NotImplemented.new(response), error_message)
        when 504
          raise(Chargify::Error::GatewayTimeout.new(response), error_message)
        end
        
        Chargify::Config.logger.debug("[CHARGIFY] Response from #{self.base_uri}#{path} was #{response.code}: #{response.body}") if Chargify::Config.debug

        response
      end

    end

    attr_reader :errors

    def initialize(options={})
      Chargify::Config.api_key = options[:api_key] if options[:api_key]
      Chargify::Config.subdomain = options[:subdomain] if options[:subdomain]
      Chargify::Config.direct_api_id = options[:direct_api_id] if options[:direct_api_id]
      Chargify::Config.direct_api_password = options[:direct_api_password] if options[:direct_api_password]

      @errors = []
      self.attributes = attrs
    end

    def attributes=(attrs)
      attrs.each do |k, v|
        self.send(:"#{k}=", v) if self.respond_to?(:"#{k}=")
      end
    end

    def api_request(type, path, options={})
      @errors = []
      begin
        self.class.api_request(type, path, options)
      rescue Chargify::Error::Base => e
        if e.response.is_a?(Hash)
          if e.response.has_key?("errors")
            @errors = [*e.response["errors"]["error"]]
          else
            @errors = [e.response.body]
          end
        else
          @errors = [e.message]
        end
        raise
      end
    end


  end
end

