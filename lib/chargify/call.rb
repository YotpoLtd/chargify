module Chargify
  class Call < Base

    class << self
      def find!(id)
        request = api_request(:get, "/calls/#{id}", {}, 2)
        response = Hashie::Mash.new(request)
        response.call.response
      end

      def find(id)
        find!(id)
      rescue Chargify::Error::Base => e
        return nil
      end
    end
  end
end