module Fire

  class SingleNestedModel < NestedModel

    class << self

      def has_path_keys(*keys)
        raise PathKeysNotSupported.new(self)
      end

      def folder_content(parent)
        init_empty_parent_object(parent)
        parent_original = parent.send(folder)
        new(parent_original.clone.merge(parent.path_data), parent_original)
      end

      def id_key
        parent.id_key
      end

      def set_id_key(value)
        raise IdKeyNotSupported.new(self)
      end

      protected

      def default_path_keys
        []
      end

      def default_folder_name
        name
      end

      def init_empty_parent_object(parent)
        unless parent.send(folder)
          parent.send("#{folder}=", {})
        end
      end

      def validate_id_key!
        true
      end

    end

    class IdKeyNotSupported < FireModelError
      def initialize(single_nested_model)
        super("Single Model #{single_nested_model} don't support own ID key.")
      end
    end

    class PathKeysNotSupported < FireModelError
      def initialize(single_nested_model)
        super("Single Model #{single_nested_model} don't support own path keys.")
      end
    end

  end

end
