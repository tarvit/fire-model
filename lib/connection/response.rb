module Fire
  module Connection
    require 'active_support/all'

    class Response
      attr_reader :raw_response, :path
      delegate :status, to: :response

      def initialize(raw_response, path)
        @raw_response = raw_response
        @path = path
        Fire.logger.response(@raw_response, path)
      end

      def body
        JSON.parse(raw_response.body, :quirks_mode => true)
      end

    end
  end
end
