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

      CONTROLLER_ACTIONS = ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy'].freeze

      no_tasks { attr_accessor :scaffold_name, :user_class, :has_many, :column_types, :model_attributes, :controller_actions, :custom_orm, :skip_authentication, :skip_model, :skip_migration, :skip_serializer, :skip_timestamps, :skip_controller, :skip_pagination, :reference, :resources, :description_method_name }

      argument :args_for_c_m, :type => :array, :default => [], :banner => 'model:attributes'

      class_option :user_class, type: :string, default: 'User', desc: "User's model name"
      class_option :reference, :desc => 'Reference to user', :type => :boolean
      class_option :has_many, :desc => 'Association with user', :type => :boolean, default: true
      class_option :resources, :desc => 'Resources routes', :type => :boolean, default: true
      class_option :custom_orm, type: :string, default: 'ActiveRecord', desc: "ORM i.e. ActiveRecord, mongoid"
      class_option :skip_model, :desc => 'Don\'t generate a model or migration file.', :type => :boolean
      class_option :skip_controller, :desc => 'Don\'t generate a controller.', :type => :boolean
      class_option :skip_migration, :desc => 'Don\'t generate migration file for model.', :type => :boolean
      class_option :skip_serializer, :desc => 'Don\'t generate serializer file for model.', :type => :boolean
      class_option :skip_timestamps, :desc => 'Don\'t add timestamps to migration file.', :type => :boolean
      class_option :skip_pagination, :desc => 'Don\'t add pagination to index method.', :type => :boolean
      class_option :skip_authentication, :desc => 'Don\'t require authentication for this controller.', :type => :boolean
      class_option :description_method_name, type: :string, default: 'desc', desc: "desc or description"

      source_root File.expand_path('../templates', __FILE__)

      def initialize(*args, &block)
        super
        @controller_actions = []
        @model_attributes = []

        @user_class = options.user_class.underscore
        @reference = options.reference?
        @has_many = options.has_many?
        @resources = options.resources?

        @custom_orm = options.custom_orm
        @skip_model = options.skip_model?
        @skip_controller = options.skip_controller?
        @skip_migration = options.skip_migration?
        @skip_serializer = options.skip_serializer?
        @skip_timestamps = options.skip_timestamps?
        @skip_authentication = options.skip_authentication?
        @skip_pagination = options.skip_pagination?
        @description_method_name = @skip_authentication ? 'desc' : 'description'

        args_for_c_m.each do |arg|
          if arg.include?(':') || !CONTROLLER_ACTIONS.include?(arg)
            @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          else
            @controller_actions << arg
            @controller_actions << 'create' if arg == 'new'
            @controller_actions << 'update' if arg == 'edit'
          end
        end

        # Default controller actions
        if @controller_actions.blank?
          @controller_actions = ['show', 'create', 'update', 'destroy']
          @controller_actions << 'index' if @resources
        end

        # Get attribute's name
        @attributes = [:id]
        @attributes += @model_attributes.select { |a| a.type != 'references' }.map { |a| a.name.to_sym }

        # if model referenced to any parent model
        @belongs_to = @model_attributes.select { |a| a.type == 'references' }.map(&:name)
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
        create_template "model.rb", "app/models/#{singular_name}.rb", belongs_to: @belongs_to unless skip_model
        migration_template "create_migration.rb", "db/migrate/create_#{singular_name}s.rb" if !skip_migration && custom_orm == 'ActiveRecord'

        @class_name = class_name
        unless skip_serializer
          create_template "active_serializer.rb", "app/serializers/active_serializer.rb"
          create_template "serializer.rb", "app/serializers/#{singular_name}_serializer.rb", attributes: @attributes, belongs_to: @belongs_to
        end
      end

      desc "Generates controller with the given NAME."
      def copy_controller_and_spec_files
        template "controller.rb", "app/controllers/api/v1/#{controller_file_name}.rb" unless skip_controller

        # inject_into_file "app/controllers/api/v1/controllers.rb", "\n mount API::V1::#{controller_class_name} \n"
        inject_into_file "app/controllers/api/v1/controllers.rb", "\n\t\t\tmount API::V1::#{controller_class_name}", after: /Grape::API.*/
      end
    end
  end
end
