# frozen_string_literal: true

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

      CONTROLLER_ACTIONS = %w[index show new create edit update destroy].freeze

      no_tasks { attr_accessor :scaffold_name, :wrapper, :user_class, :has_many, :column_types, :model_attributes, :controller_actions, :custom_orm, :initial_setup, :skip_tips, :skip_authentication, :skip_model, :skip_migration, :skip_serializer, :skip_timestamps, :skip_controller, :skip_pagination, :skip_swagger, :reference, :reference_name, :reference_name_create_update, :reference_id_param, :resources, :description_method_name }

      argument :args_for_c_m, type: :array, default: [], banner: 'model:attributes'

      class_option :wrapper, type: :string, default: 'V1', desc: 'Skip "Swagger UI"'
      class_option :user_class, type: :string, desc: "User's model name"
      class_option :reference, desc: 'Reference to user', type: :boolean
      class_option :reference_name, type: :string, default: 'current_user', desc: 'Reference Name'
      class_option :has_many, desc: 'Association with user', type: :boolean
      class_option :resources, desc: 'Resources routes', type: :boolean, default: true
      class_option :custom_orm, type: :string, default: 'ActiveRecord', desc: 'ORM i.e. ActiveRecord, mongoid'
      class_option :initial_setup, type: :boolean, default: false, desc: 'Skip "Initial Setup i.e. Routes, Base models, etc."'
      class_option :skip_swagger, type: :boolean, default: false, desc: 'Skip "Swagger UI"'
      class_option :skip_tips, type: :boolean, default: false, desc: 'Skip "Tips from different files i.e. model, serializer, etc."'
      class_option :skip_model, desc: 'Don\'t generate a model or migration file.', type: :boolean
      class_option :skip_controller, desc: 'Don\'t generate a controller.', type: :boolean
      class_option :skip_migration, desc: 'Don\'t generate migration file for model.', type: :boolean
      class_option :skip_serializer, desc: 'Don\'t generate serializer file for model.', type: :boolean
      class_option :skip_timestamps, desc: 'Don\'t add timestamps to migration file.', type: :boolean
      class_option :skip_pagination, desc: 'Don\'t add pagination to index method.', type: :boolean
      class_option :skip_authentication, desc: 'Don\'t require authentication for this controller.', type: :boolean
      class_option :description_method_name, type: :string, default: 'desc', desc: 'desc or description'

      source_root File.expand_path('templates', __dir__)

      def initialize(*args, &block)
        super
        @controller_actions = []
        @model_attributes = []

        @wrapper = options.wrapper

        @reference = options.reference?
        @resources = options.resources?

        @has_many = options.has_many?
        @reference_name = options.reference_name
        @user_class = options.user_class&.underscore
        if @reference_name.match(/current_/)
          @reference_name_create_update = @reference_name
          @user_class = @reference_name.gsub(/current_/, '').underscore unless @user_class
        else
          @user_class = @reference_name.underscore unless @user_class
          @reference_id_param = get_attribute_name(@reference_name.underscore, 'references')
          @reference_name_create_update = "#{@reference_name}.find(params[:#{singular_name}][:#{reference_id_param}])"
          @reference_name = "#{@reference_name}.find(params[:#{reference_id_param}])"
        end

        @custom_orm = options.custom_orm
        @initial_setup = options.initial_setup?
        @skip_tips = options.skip_tips?
        @skip_swagger = options.skip_swagger?
        @skip_model = options.skip_model?
        @skip_controller = options.skip_controller?
        @skip_migration = options.skip_migration?
        @skip_serializer = options.skip_serializer?
        @skip_timestamps = options.skip_timestamps?
        @skip_pagination = options.skip_pagination?

        # skip authentication if authenticator not found
        @skip_authentication = options.skip_authentication?
        @skip_authentication = true unless File.exist?(File.join(destination_root, 'app/controllers/api/authenticator.rb'))
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
          @controller_actions = %w[show create update destroy]
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

      def self.next_migration_number(_path)
        if @prev_migration_nr
          @prev_migration_nr += 1
        else
          @prev_migration_nr = Time.now.utc.strftime('%Y%m%d%H%M%S').to_i
        end
        @prev_migration_nr.to_s
      end

      def copy_initializer
        create_template 'application_record.rb', 'app/models/application_record.rb', skip_if_exist: true
        create_template 'swagger.rb', 'config/initializers/swagger.rb', skip_if_exist: true unless skip_swagger

        create_template 'base.rb', 'app/controllers/api/base.rb', skip_if_exist: true
        create_template 'custom_description.rb', 'app/controllers/api/custom_description.rb', skip_if_exist: true
        create_template 'responder.rb', 'app/controllers/api/responder.rb'

        create_template 'controllers.rb', "app/controllers/api/#{@wrapper.underscore}/controllers.rb", skip_if_exist: true unless skip_controller
        create_template 'defaults.rb', "app/controllers/api/#{@wrapper.underscore}/defaults.rb", skip_if_exist: true

        inject_into_file 'app/controllers/api/base.rb', "\n\t\t\tmount Api::#{wrapper.capitalize}::Controllers", after: /Grape::API.*/

        if initial_setup
          inject_into_file 'config/routes.rb', "\n\tmount GrapeSwaggerRails::Engine => '/swagger'", after: /routes.draw.*/ unless skip_swagger
          inject_into_file 'config/routes.rb', "\n\tmount Api::Base, at: '/'", after: /routes.draw.*/
        end
      end

      desc 'Generates model with the given NAME.'
      def create_model_file
        # create module model & migration
        create_template 'model.rb', "app/models/#{singular_name}.rb", attributes: @attributes.map(&:name), references: @references.map(&:name), polymorphics: @polymorphics.map(&:name) unless skip_model
        inject_into_file "app/models/#{@user_class}.rb", "\n\thas_many :#{plural_name}, dependent: :destroy", after: /class #{@user_class.humanize} < ApplicationRecord.*/ unless skip_model
        create_migration_file 'module_migration.rb', "db/migrate/create_#{plural_name}.rb" if !skip_migration && custom_orm == 'ActiveRecord'

        # create active serializer & module serializer
        unless skip_serializer
          create_template 'active_serializer.rb', 'app/serializers/active_serializer.rb', skip_if_exist: true
          create_template 'serializer.rb', "app/serializers/#{singular_name}_serializer.rb", attributes: [:id] + @attributes.map(&:name), references: @references.map(&:name), polymorphics: @polymorphics.map(&:name)
        end
      end

      desc 'Generates controller with the given NAME.'
      def copy_controller_and_spec_files
        template 'controller.rb', "app/controllers/api/#{@wrapper.underscore}/#{controller_file_name}.rb" unless skip_controller

        inject_into_file "app/controllers/api/#{@wrapper.underscore}/controllers.rb", "\n\t\t\tmount Api::#{@wrapper.capitalize}::#{controller_class_name}", after: /Grape::API.*/
      end
    end
  end
end
