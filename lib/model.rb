module Fire
  require 'ostruct'
  require 'active_support'

  class Model < OpenStruct

    LEVEL_SEPARATOR = ?/

    cattr_accessor :firebase_path
    cattr_accessor :global_fire_collection, :global_path_keys

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

    def collection_name
      self.class.collection_name
    end

    def save
      self.class.new(@original_data).delete if path_changed?
      self.class.connection.set(path, self.data)
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
      self.class.path_keys.map do |pk|
        path_value = send(pk)
        raise PathValueMissingError.new(pk) if path_value.to_s.empty?
        self.class.path_value_param(path_value)
      end
    end

    def custom_data(hash=self.data)
      res = hash.to_a.select do |(k, v)|
        !self.class.path_keys.include?(k)
      end
      self.class.prepare_hash(res)
    end

    def path_data(hash=self.data)
      res = hash.to_a.select do |(k, v)|
        self.class.path_keys.include?(k.to_sym)
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

    class << self

      # Klass Setters

      def in_collection(name)
        self.global_fire_collection ||= {}
        self.global_fire_collection[default_collection_name]  = name
      end

      def has_path_keys(*keys)
        self.global_path_keys ||= {}
        self.global_path_keys[default_collection_name]=keys
      end

      # Klass Accessors

      def collection_name
        custom_name = (global_fire_collection && global_fire_collection[default_collection_name])
        custom_name || default_collection_name
      end

      def connection
        Fire::Connection::Request.new
      end

      def path_keys
        own_path_keys + default_path_keys
      end

      def own_path_keys
        (self.global_path_keys || { })[default_collection_name] ||= []
      end

      # Record Methods

      def query(params={}, &filter_condition)
        path_values, selected_keys = [], []

        own_path_keys.each do |key|
          if params[key]
            path_values << path_value_param(params[key])
            selected_keys << key
          else
            break
          end
        end

        full_path = ([ collection_name ] + path_values) * LEVEL_SEPARATOR
        response = connection.get(full_path).body

        return [] if response.nil?
        result = response.values

        (own_path_keys - selected_keys).count.times do
          result = result.map(&:values).flatten.compact
        end

        filter = params.clone
        selected_keys.each do |sk|
          filter.delete(sk)
        end

        result.map{|data| new(data) }.select do |model_object|
          not_filtered_by_attributes = model_object.has_data?(filter)
          not_filtered_by_block = block_given? ? filter_condition.(model_object) : true
          not_filtered_by_attributes && not_filtered_by_block
        end
      end

      alias_method :all, :query

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
        :id
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

  end
end