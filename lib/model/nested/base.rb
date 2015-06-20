module Fire

  class NestedModel < Model
    non_shared_cattr_accessor :parent, :nested_options

    def saving_data
      return super() if nested_options.parent_values

      self.class.parent.all_path_keys.each_with_object( data.clone) do |k, res|
        res.delete(k)
      end
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
        objects = self.down_levels(parent.send(folder), levels_count)
        objects.map{|x|
          full_data = x.merge(parent.path_data)
          new(full_data)
        }
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

  end

end
