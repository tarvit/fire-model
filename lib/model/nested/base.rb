module Fire

  class NestedModel < Model
    non_shared_cattr_accessor :parent, :nested_options

    def initialize(hash, parent_original={})
      @parent_original = parent_original
      super(hash)
    end

    def sync_parent
      @parent_original.merge!(saving_data)
    end

    def saving_data
      return super() if nested_options.parent_values

      self.class.parent.all_path_keys.each_with_object(data.clone) do |k, res|
        res.delete(k)
      end
    end

    def save
      sync_parent
      super
    end

    def nested_options
      self.class.nested_options
    end

    class << self
      def in_collection(name)
        raise CollectionIsSetError.new(self)
      end

      def has_path_keys(*keys)
        raise ParentModelNotSetError.new(self) unless self.parent
        super(*keys)
        keys.each do |key|
          raise DuplicatedParentPathKeyError.new(key, self.parent) if self.parent.all_path_keys.include?(key)
        end
      end

      def nested_in(parent, options={})
        self.parent = parent
        self.nested_options = OpenStruct.new(options)
        self.parent.has_nested(self)
      end

      def own_path_keys
        parent.all_path_keys + [ folder ] + super()
      end

      def collection_name
        parent.collection_name
      end

      def folder
        path_value_param(self.nested_options.folder ? self.nested_options.folder : default_folder_name)
      end

      def folder_content(parent)
        levels_count = (path_keys || []).count
        nested_folder = parent.send(folder) || {}
        objects = self.down_levels(nested_folder, levels_count)
        objects.map{|parent_original|
          full_data = parent_original.clone.merge(parent.path_data)
          new(full_data, parent_original)
        }
      end

      def query(params={}, &filter_condition)
        raise QueryingNotSupportedError.new
      end

      def all
        query
      end

      protected

      def default_folder_name
        name.pluralize
      end
    end

    def method_missing(*args)
      if args.first.to_s == self.class.folder
        self.class.folder
      else
        super
      end
    end

    class DuplicatedParentPathKeyError < InvalidPathKeyError
      def initialize(key, parent)
        message = "Key '#{key}' is duplicated in a Parent Model '#{parent}'"
        super(key, message)
      end
    end

    class ParentModelNotSetError < FireModelError
      def initialize(nested_model)
        super("Nested Model '#{nested_model}' has no Parent Model set. Call `nested_in` to set a Parent.")
      end
    end

    class CollectionIsSetError < FireModelError
      def initialize(nested_model)
        super("Nested Model '#{nested_model}' can not have own Collection. It is extended from Parent Model '#{nested_model.parent}'")
      end
    end

    class QueryingNotSupportedError < FireModelError
      def initialize
        super("Nested Models do not support querying")
      end
    end

  end

end
