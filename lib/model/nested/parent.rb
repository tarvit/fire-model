module Fire
  class NestedModel
    module Parent
      extend ActiveSupport::Concern

      included do
        non_shared_cattr_accessor :assigned_nested_models
      end

      module ClassMethods

        def has_nested(nested_model)
          self.assigned_nested_models ||= []
          self.assigned_nested_models << nested_model

          folder = nested_model.folder
          define_method "nested_#{folder}" do
            nested_model.folder_content(self)
          end

          define_method "add_to_#{folder}" do |object|
            nested_model.create(object.merge(self.path_data))
          end
        end

        def nested_models
          self.assigned_nested_models || []
        end

      end

    end
  end
end
