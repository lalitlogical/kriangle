module Kriangle
  module Generators
    # Some helpers for generating scaffolding
    module GeneratorHelpers
      attr_accessor :options, :attributes

      @@column_types = {
        'references': 'Integer',
        'text': 'String',
        'datetime': 'DateTime'
      }

      private
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

        def create_template template_fname, fname, **options
          @options = options

          if @options[:skip_template] && File.exist?(File.join(destination_root, fname))
            say_status "skipped", fname
          else
            template template_fname, fname
          end
        end

        def get_record_not_found_exception
          custom_orm == 'Mongoid' ? 'Mongoid::Errors::DocumentNotFound' : 'ActiveRecord::RecordNotFound'
        end

        def get_record_invalid_exception
          custom_orm == 'Mongoid' ? 'Mongoid::Errors::InvalidFind' : 'ActiveRecord::RecordInvalid'
        end

        def get_attribute_name name, attribute_type
          attribute_type == 'references' ? "#{name}_id" : name
        end

        def get_attribute_type attribute_type
          column_type = @@column_types[attribute_type.to_sym]
          column_type.present? ? column_type : attribute_type.to_s.camelcase
        end
    end
  end
end
