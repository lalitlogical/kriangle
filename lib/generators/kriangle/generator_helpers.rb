module Kriangle
  module Generators
    # Some helpers for generating scaffolding
    module GeneratorHelpers
      attr_accessor :options, :attributes
      
      private
        def show_authenticate?
          !options['skip_authentication']
        end

        def model_columns_for_attributes
          class_name.constantize.columns.reject do |column|
            column.name.to_s =~ /^(id|user_id|created_at|updated_at)$/
          end
        end

        def editable_attributes
          attributes ||= model_columns_for_attributes.map do |column|
            Rails::Generators::GeneratedAttribute.new(column.name.to_s, column.type.to_s)
          end
        end
    end
  end
end
