module Fire

  class SingleNestedModel < NestedModel

    class << self

      def has_path_keys(*keys)
        raise PathKeysNotSupported.new(self)
      end

      def folder_content(parent)
        object = parent.send(folder) || {}
        new(object.merge(parent.path_data))
      end

      protected

      def default_path_keys
        []
      end

      def default_folder_name
        name
      end

    end

    class PathKeysNotSupported < FireModelError
      def initialize(single_nested_model)
        super("Single Model #{single_nested_model} don't support own path keys.")
      end
    end

  end

end
