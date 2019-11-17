# frozen_string_literal: true

module Kriangle
  module Generators
    # Some helpers for generating scaffolding
    module GeneratorHelpers
      attr_accessor :options, :attributes

      Attribute = Struct.new(:name, :type, :required, :search_by, :default)
      Association = Struct.new(:association_type, :association_name, :required, :counter_cache, :foreign_key, :class_name, :reference) do
        def association_type_with_name
          "#{association_type} :#{association_name}"
        end

        def association
          txt = "#{association_type} :#{association_name}"
          txt += ", foreign_key: '#{foreign_key}'" if foreign_key.present?
          txt += ", class_name: '#{class_name}'" if class_name.present?
          txt += ", counter_cache: true" if counter_cache == 'true'
          txt += ", dependent: :destroy" if association_type.match('has_')
          txt
        end
      end

      @@column_types = {
        'references': 'Integer',
        'text': 'String',
        'datetime': 'DateTime',
        'attachment': 'File',
        'jsonb': 'JSON'
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

      def create_template(template_fname, fname, **options)
        @options = options
        if @options[:skip_if_exist] && File.exist?(File.join(destination_root, fname))
          say_status 'skipped', fname
        else
          template template_fname, fname
        end
      end

      def create_migration_file(migration_fname, fname, **options)
        @options = options
        if @options[:skip_if_exist] && self.class.migration_exists?('db/migrate', fname.split('/').last.gsub('.rb', ''))
          say_status('skipped', "Migration '#{fname}' already exists")
        else
          migration_template migration_fname, fname, options
        end
      end

      def get_record_not_found_exception
        custom_orm == 'Mongoid' ? 'Mongoid::Errors::DocumentNotFound' : 'ActiveRecord::RecordNotFound'
      end

      def get_record_invalid_exception
        custom_orm == 'Mongoid' ? 'Mongoid::Errors::InvalidFind' : 'ActiveRecord::RecordInvalid'
      end

      def get_attribute_name(name, attribute_type)
        attribute_type == 'references' ? "#{name}_id" : name
      end

      def require_or_optional(attribute)
        attribute.required == 'true' ? 'requires' : 'optional'
      end

      def get_attribute_type(attribute_type)
        column_type = @@column_types[attribute_type.to_sym]
        column_type.present? ? column_type : attribute_type.to_s.camelcase
      end
    end
  end
end
