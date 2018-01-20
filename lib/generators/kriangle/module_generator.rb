require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'
require 'generators/kriangle/generator_helpers'

module Kriangle
  module Generators
    # Custom scaffolding generator
    class ModuleGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include Kriangle::Generators::GeneratorHelpers

      class_option :custom_orm, type: :string, default: 'ActiveRecord', desc: "ORM i.e. ActiveRecord, mongoid"

      source_root File.expand_path('../templates', __FILE__)

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      def create_model_file
        template "model.rb", "app/models/#{singular_name}.rb" unless options['skip_model']
        migration_template "create_migration.rb", "db/migrate/create_#{singular_name}s.rb" if options['custom_orm'] == 'ActiveRecord'

        template "active_serializer.rb", "app/serializers/active_serializer.rb"
        template "serializer.rb", "app/serializers/#{singular_name}_serializer.rb"
      end

      desc "Generates model, controller with the given NAME."
      def copy_controller_and_spec_files
        template "controller.rb", "app/controllers/api/v1/#{controller_file_name}.rb" unless options['skip_controller']

        # inject_into_file "app/controllers/api/v1/controllers.rb", "\n mount API::V1::#{controller_class_name} \n"
        inject_into_file "app/controllers/api/v1/controllers.rb", "\n\t\t\tmount API::V1::#{controller_class_name}", after: /Grape::API.*/
      end
    end
  end
end
