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

      no_tasks { attr_accessor :scaffold_name, :model_attributes, :controller_actions }

      argument :args_for_c_m, :type => :array, :default => [], :banner => 'model:attributes'

      class_option :custom_orm, type: :string, default: 'ActiveRecord', desc: "ORM i.e. ActiveRecord, mongoid"
      class_option :skip_model, :desc => 'Don\'t generate a model or migration file.', :type => :boolean
      class_option :skip_migration, :desc => 'Don\'t generate migration file for model.', :type => :boolean
      class_option :skip_timestamps, :desc => 'Don\'t add timestamps to migration file.', :type => :boolean

      source_root File.expand_path('../templates', __FILE__)

      def initialize(*args, &block)
        super
        @controller_actions = []
        @model_attributes = []
        @skip_model = options.skip_model?

        args_for_c_m.each do |arg|
          if arg.include?(':')
            @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          else
            @controller_actions << arg
            @controller_actions << 'create' if arg == 'new'
            @controller_actions << 'update' if arg == 'edit'
          end
        end
      end

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      desc "Generates model with the given NAME."
      def create_model_file
        @class_name = class_name
        template "model.rb", "app/models/#{singular_name}.rb" unless options['skip_model']
        migration_template "create_migration.rb", "db/migrate/create_#{singular_name}s.rb" if !options['skip_migration'] && options['custom_orm'] == 'ActiveRecord'

        @class_name = class_name
        template "active_serializer.rb", "app/serializers/active_serializer.rb"
        template "serializer.rb", "app/serializers/#{singular_name}_serializer.rb"
      end

      desc "Generates controller with the given NAME."
      def copy_controller_and_spec_files
        template "controller.rb", "app/controllers/api/v1/#{controller_file_name}.rb" unless options['skip_controller']

        # inject_into_file "app/controllers/api/v1/controllers.rb", "\n mount API::V1::#{controller_class_name} \n"
        inject_into_file "app/controllers/api/v1/controllers.rb", "\n\t\t\tmount API::V1::#{controller_class_name}", after: /Grape::API.*/
      end
    end
  end
end
