module Fire
  module Connection
    require 'active_support/all'

    class Response
      attr_reader :response
      delegate :status, to: :response

      def initialize(response)
        @response = response
      end

      def body
        JSON.parse(response.body, :quirks_mode => true)
      end

    end
  end
end
