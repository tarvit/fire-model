module Fire
  require 'connection/response'
  require 'connection/request'
  require 'model/base'

  require 'ostruct'

  def self.setup(options)
    configuration = {}
    configuration[:base_uri] = base_uri(options[:firebase_path])
    configuration[:auth] = (options[:firebase_auth] || {})
    @config = OpenStruct.new(configuration)
  end

  def self.config
    @config
  end

  def self.drop!
    connection.delete(?/)
  end

  def self.tree
    connection.get(?/).body
  end

  def self.connection
    Fire::Connection::Request.new
  end

  private

  def self.base_uri(uri)
    raise ArgumentError.new('base_uri must be a valid https uri') if uri !~ URI::regexp(%w(https))
    uri.end_with?(?/) ? uri : (uri + ?/)
  end
end