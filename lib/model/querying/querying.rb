module Fire
  class Model
    module Querying

      extend ActiveSupport::Concern

      module ClassMethods
        def query(params={}, &filter_condition)
          direct_keys = direct_path_keys(params)
          full_path = ([ collection_name ] + direct_path_values(params, direct_keys)) * LEVEL_SEPARATOR

          response = connection.get(full_path).body
          return [] if response.nil?

          needed_levels = (all_path_keys - direct_keys - default_path_keys).count
          rows = down_levels(response, needed_levels)

          filter_result(rows, filter_opts(params, direct_keys), filter_condition)
        end

        alias_method :all, :query

        def down_levels(root, levels_count)
          result = root.values

          levels_count.times do
            result = result.map(&:values).flatten.compact
          end

          result
        end

        def filter_result(rows, filter_opts, filter_condition)
          rows.map{|data| new(data) }.select do |model_object|
            not_filtered_by_attributes = model_object.has_data?(filter_opts)
            not_filtered_by_block = filter_condition ? filter_condition.(model_object) : true
            not_filtered_by_attributes && not_filtered_by_block
          end
        end

        def direct_path_keys(params)
          res = []
          own_path_keys.each do |key|
            params[key] ? (res << key) : break
          end
          res
        end

        def direct_path_values(params, direct_keys)
          direct_keys.map do |dpk|
            path_value_param(params[dpk])
          end
        end

        def filter_opts(params, direct_keys)
          direct_keys.each_with_object(params.clone) do |sk, res|
            res.delete(sk)
          end
        end

      end
    end
  end
end