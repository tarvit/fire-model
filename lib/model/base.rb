module Fire
  require 'ostruct'
  require 'active_support'
  require 'tarvit-helpers'

  class Model < OpenStruct
    include TarvitHelpers::NonSharedAccessors
    LEVEL_SEPARATOR = ?/

    non_shared_cattr_accessor :fire_collection, :path_keys, :id_key_name

    def initialize(attrs={})
      data = self.class.prepare_hash(attrs)
      unless data[id_key]
        data[id_key] = self.class.next_id
        @persisted = false
      else
        @persisted = true
      end
      @original_data = data.clone
      super(data)
    end

    # Record Methods

    def id_key
      self.class.id_key
    end

    def id_value
      send(id_key)
    end

    def collection_name
      self.class.collection_name
    end

    def save
      self.class.new(@original_data).delete if path_changed?
      self.class.connection.set(path, self.saving_data)
      @persisted = true
    end

    def delete
      self.class.connection.delete(path)
      @persisted = false
    end

    def persisted?
      @persisted
    end

    def path
      ([ collection_name ] + path_values) * LEVEL_SEPARATOR
    end

    # Data Methods

    def path_values
      self.class.all_path_keys.map do |pk|
        path_value = send(pk)
        raise PathValueMissingError.new(pk) if path_value.to_s.empty?
        self.class.path_value_param(path_value)
      end
    end

    def custom_data(hash=self.data)
      res = hash.to_a.select do |(k, v)|
        !self.class.all_path_keys.include?(k)
      end
      self.class.prepare_hash(res)
    end

    def path_data(hash=self.data)
      res = hash.to_a.select do |(k, v)|
        self.class.all_path_keys.include?(k.to_sym)
      end
      self.class.prepare_hash(res)
    end

    def path_changed?
      @persisted && (path_data != path_data(@original_data))
    end

    def has_data?(data)
      return true if data.empty?
      self.class.prepare_hash(data).each do |k, v|
        return false unless self.send(k) == v
      end
      true
    end

    def ==(model_object)
      self.data == model_object.data
    end

    def data
      self.to_h
    end

    def saving_data
      data
    end

    class << self

      # Klass Setters

      def in_collection(name)
        self.fire_collection = name
      end

      def has_path_keys(*keys)
        self.path_keys = keys
      end

      def set_id_key(value)
        self.id_key_name = value
      end

      # Klass Accessors

      def collection_name
        self.fire_collection || default_collection_name
      end

      def connection
        Fire::Connection::Request.new
      end

      def all_path_keys
        own_path_keys + default_path_keys
      end

      def own_path_keys
        self.path_keys || []
      end

      # Record Methods

      def take(path_data)
        path_object = new(path_data)
        loaded_data = connection.get(path_object.path).body
        loaded_data.nil? ? nil : new(loaded_data)
      end

      def create(object)
        model = new(object)
        model.save
        model
      end

      # Helpers

      def next_id
        rand(36**8).to_s(36)
      end

      def path_value_param(raw_value)
        return raw_value.to_s+?_ if raw_value.is_a?(Numeric)
        raw_value.to_s.parameterize
      end

      def prepare_hash(hash)
        HashWithIndifferentAccess[hash]
      end

      def id_key
        self.id_key_name || :id
      end

      protected

      def default_collection_name
        ActiveSupport::Inflector.demodulize(name)
      end

      def default_path_keys
        [ id_key ]
      end

    end

    class FireModelError < StandardError; end

    class PathValueMissingError < FireModelError
      def initialize(key)
        super "Required path key '#{ key }' is not set!"
      end
    end

    class InvalidPathKeyError < FireModelError
      def initialize(key, message=nil)
        super (message || "Path key '#{ key }' is invalid")
      end
    end

    require_relative './querying/querying'
    require_relative './nested/base'
    require_relative './nested/single'
    require_relative './nested/parent'
    include Querying
    include NestedModel::Parent
  end
end
