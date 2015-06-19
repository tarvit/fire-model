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
        end

        def nested_models
          self.assigned_nested_models || []
        end

      end

    end
  end
end
