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

      no_tasks { attr_accessor :scaffold_name, :wrapper, :user_class, :has_many, :column_types, :model_attributes, :controller_actions, :custom_orm, :skip_authentication, :skip_model, :skip_migration, :skip_serializer, :skip_timestamps, :skip_controller, :skip_pagination, :reference, :resources, :description_method_name }

      argument :args_for_c_m, :type => :array, :default => [], :banner => 'model:attributes'

      class_option :wrapper, type: :string, default: "V1", desc: "Skip \"Swagger UI\""
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

        @wrapper = options.wrapper
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
        @attributes = []
        @references = []
        @polymorphics = []

        # get different types of attributes
        @model_attributes.each do |attribute|
          if attribute.type.to_s.match('polymorphic').present?
            @polymorphics << attribute
          elsif attribute.type.to_s.match('references').present?
            @references << attribute
          else
            @attributes << attribute
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
        # create module model & migration
        create_template "model.rb", "app/models/#{singular_name}.rb", attributes: @attributes.map(&:name), references: @references.map(&:name), polymorphics: @polymorphics.map(&:name) unless skip_model
        create_migration_file "module_migration.rb", "db/migrate/create_#{plural_name}.rb" if !skip_migration && custom_orm == 'ActiveRecord'

        # create active serializer & module serializer
        unless skip_serializer
          create_template "active_serializer.rb", "app/serializers/active_serializer.rb", skip_if_exist: true
          create_template "serializer.rb", "app/serializers/#{singular_name}_serializer.rb", attributes: [:id] + @attributes.map(&:name), references: @references.map(&:name), polymorphics: @polymorphics.map(&:name)
        end
      end

      desc "Generates controller with the given NAME."
      def copy_controller_and_spec_files
        template "controller.rb", "app/controllers/api/#{@wrapper.underscore}/#{controller_file_name}.rb" unless skip_controller

        inject_into_file "app/controllers/api/#{@wrapper.underscore}/controllers.rb", "\n\t\t\tmount API::#{@wrapper.capitalize}::#{controller_class_name}", after: /Grape::API.*/
      end
    end
  end
end
