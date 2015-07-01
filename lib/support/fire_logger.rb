class FireLogger < ::Logger

  module Ext

    def request(method, path)
      debug "[REQUEST] #{method}: #{path}"
    end

    def timed_out(method, path)
      error "[TIMED OUT] #{method}: #{path}"
    end

    def response(response_value, path)
      debug "[RESPONSE] #{response_value.status}: #{ path }"
    end

  end

  include Ext

  class << self
    def create(options)
      new(STDOUT)
    end
  end

end
