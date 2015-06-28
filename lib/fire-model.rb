module Fire
  require 'connection/response'
  require 'connection/request'
  require 'model/base'

  require 'support/fire_logger'

  require 'ostruct'
  ROOT = ?/

  class << self

    def setup(options)
      configuration = {}
      configuration[:base_uri] = base_uri(options[:firebase_path])
      configuration[:auth] = (options[:firebase_auth] || {})
      setup_logger(options)
      @config = OpenStruct.new(configuration)
    end

    def config
      @config
    end

    def logger
      @logger
    end

    def logger=(logger)
      logger.extend(FireLogger::Ext)
      @logger = logger
    end

    def connection
      Fire::Connection::Request.new
    end

    def drop!
      connection.delete(ROOT)
    end

    def tree
      connection.get(ROOT).body
    end

    def reset_tree!(data=nil)
      connection.set(ROOT, data)
    end

    private

    def setup_logger(options)
      @logger = FireLogger.create(options)
    end

  end

  private

  def self.base_uri(uri)
    raise ArgumentError.new('base_uri must be a valid https uri') if uri !~ URI::regexp(%w(https))
    uri.end_with?(?/) ? uri : (uri + ?/)
  end
end