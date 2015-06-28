module Fire
  module Connection
    class Request
      require 'httpclient'
      require 'json'

      def initialize
        @client = HTTPClient.new(base_url: Fire.config.base_uri)
        @client.connect_timeout = Fire.config.timeout || 120
        @client.default_header['Content-Type'] = 'application/json'
      end

      [ :get, :delete ].each do |method_type|
        method = <<METHOD
        def #{method_type}(path, query={})
          process(:#{method_type}, path, query)
        end
METHOD
        class_eval(method)
      end

      [ :post, :put, :patch ].each do |method_type|
        method = <<METHOD
        def #{method_type}(path, value, query={})
          process(:#{method_type}, path, query, value.to_json)
        end
METHOD
        class_eval(method)
      end

      alias_method :set, :put

      protected

      def process(method, path, query={}, body=nil, tries=5)
        raise 'Firebase Connection Failed' if tries.zero?
        begin
          Fire.logger.request(method, path)
          raw_response = @client.request(method, "#{path}.json", body: body, query: prepare_options(query), follow_redirect: true)
          Fire::Connection::Response.new(raw_response, path)
        rescue HTTPClient::ConnectTimeoutError
          Fire.logger.timed_out(method, path)
          return process(method, path, query, body, tries-1)
        end
      end

      def prepare_options(query_options)
        query_options.merge(Fire.config.auth)
      end

    end

  end
end