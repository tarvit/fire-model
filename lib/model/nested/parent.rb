module Fire
  class Model
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
            objects = self.class.down_levels(send(folder), (nested_model.path_keys || []).count)
            objects.map{|x|
              full_data = x.merge(self.path_data)
              nested_model.new(full_data)
            }
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
