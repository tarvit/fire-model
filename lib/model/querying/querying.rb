module Fire
  class Model
    module Querying

      extend ActiveSupport::Concern

      module ClassMethods
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

          result = down_levels(response, (own_path_keys - selected_keys).count)

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

        def down_levels(root, levels_count)
          result = root.values

          levels_count.times do
            result = result.map(&:values).flatten.compact
          end

          result
        end

      end
    end
  end
end