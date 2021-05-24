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

      CONTROLLER_ACTIONS = %w[index show new create edit update destroy create_or_destroy].freeze

      no_tasks do
        attr_accessor :user_class,
                      :wrapper,
                      :controller_path,
                      :column_types,
                      :attributes,
                      :model_attributes,
                      :model_associations,
                      :controller_actions,
                      :custom_orm,
                      :initial_setup,
                      :skip_tips,
                      :skip_authentication,
                      :skip_model,
                      :skip_migration,
                      :skip_serializer,
                      :skip_timestamps,
                      :skip_controller,
                      :skip_pagination,
                      :skip_swagger,
                      :reference,
                      :reference_name,
                      :reference_name_create_update,
                      :association_type,
                      :touch_record,
                      :accepts_nested_attributes,
                      :counter_cache,
                      :self_reference,
                      :parent_association_name,
                      :child_association_name,
                      :additional_where_clause,
                      :reference_id_param,
                      :creation_method,
                      :like_dislike,
                      :resources,
                      :description_method_name,
                      :search_by,
                      :database,
                      :force
      end

      argument :args_for_c_m, type: :array, default: [], banner: 'model:attributes'

      class_option :database, type: :string, desc: "database i.e. postgresql, mysql, sqlite3"

      class_option :user_class, type: :string, desc: "User's model name"
      class_option :wrapper, type: :string, default: 'V1', desc: 'Skip "Swagger UI"'
      class_option :controller_path, type: :string, desc: "controller's path"

      class_option :reference, desc: 'Reference to user', type: :boolean, default: false
      class_option :reference_name, type: :string, default: 'current_user', desc: 'Reference Name'
      class_option :association_type, desc: 'Association with any model', type: :string
      class_option :touch_record, desc: 'Touch the updated_at column', type: :boolean, default: false
      class_option :accepts_nested_attributes, desc: 'accepts nested attributes', type: :boolean, default: false
      class_option :counter_cache, desc: 'Counter cache support', type: :boolean, default: false

      class_option :self_reference, desc: 'Counter cache support', type: :boolean, default: false
      class_option :parent_association_name, type: :string, default: 'parent', desc: 'Parent Association Name'
      class_option :child_association_name, type: :string, default: 'children', desc: 'Child Association Name'

      class_option :creation_method, type: :string, default: 'new', desc: 'Creation Method'
      class_option :like_dislike, desc: 'Like Dislike', type: :boolean, default: false

      class_option :resources, desc: 'Resources routes', type: :boolean, default: true
      class_option :custom_orm, type: :string, default: 'ActiveRecord', desc: 'ORM i.e. ActiveRecord, mongoid'
      class_option :initial_setup, type: :boolean, default: false, desc: 'Skip "Initial Setup i.e. Routes, Base models, etc."'

      class_option :skip_swagger, type: :boolean, default: false, desc: 'Skip "Swagger UI"'
      class_option :skip_tips, type: :boolean, default: false, desc: 'Skip "Tips from different files i.e. model, serializer, etc."'
      class_option :skip_model, desc: 'Don\'t generate a model or migration file.', type: :boolean, default: false
      class_option :skip_controller, desc: 'Don\'t generate a controller.', type: :boolean, default: false
      class_option :skip_migration, desc: 'Don\'t generate migration file for model.', type: :boolean, default: false
      class_option :skip_serializer, desc: 'Don\'t generate serializer file for model.', type: :boolean, default: false
      class_option :skip_timestamps, desc: 'Don\'t add timestamps to migration file.', type: :boolean, default: false
      class_option :skip_pagination, desc: 'Don\'t add pagination to index method.', type: :boolean, default: false
      class_option :skip_authentication, desc: 'Don\'t require authentication for this controller.', type: :boolean, default: false
      class_option :description_method_name, type: :string, default: 'desc', desc: 'desc or description'
      class_option :force, desc: 'Force', type: :boolean, default: false

      source_root File.expand_path('templates', __dir__)

      def initialize(*args, &block)
        super
        @controller_actions = []
        @model_attributes = []
        @model_associations = []
        @attributes = []
        @references = []
        @polymorphics = []

        @user_class = options.user_class&.underscore
        @wrapper = options.wrapper
        @database = options.database
        @controller_path = options.controller_path&.classify&.pluralize || controller_class_name
        @force = options.force
        @resources = options.resources?

        @reference = options.reference?
        if @reference
          @association_type = options.association_type
          @touch_record = options.touch_record?
          @accepts_nested_attributes = options.accepts_nested_attributes?
          @counter_cache = options.counter_cache?

          @reference_name = options.reference_name
          if @reference_name.match(/current_/)
            @reference_name_create_update = @reference_name
            @user_class ||= @reference_name.gsub(/current_/, '').underscore
          else
            @user_class ||= @reference_name.underscore
            @reference_id_param = get_attribute_name(@reference_name.underscore, 'references')
            @reference_name_create_update = "#{@reference_name}.find(params[:#{reference_id_param}])"
            @reference_name = "#{@reference_name}.find(params[:#{reference_id_param}])"
          end
          @model_associations << Association.new('belongs_to', user_class, nil, 'true', counter_cache.to_s, touch_record.to_s, accepts_nested_attributes.to_s, '', '', true)
        end

        @self_reference = options.self_reference?
        if @self_reference
          @parent_association_name = options.parent_association_name
          @child_association_name = options.child_association_name
          @additional_where_clause = @self_reference ? '.only_parent' : ''
        end
        @creation_method = options.creation_method
        @like_dislike = options.like_dislike

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
            options = arg.split(':')
            if arg.match(/^ma:/).present?
              options.shift
              @model_associations << Association.new(*options)
            else
              @model_attributes << Attribute.new(*options)
            end
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
        @search_by = model_attributes.any? { |ma| ma.search_by.present? }

        # get different types of attributes
        @model_attributes.uniq!(&:name)
        @model_attributes.each do |attribute|
          if attribute.type.match('polymorphic').present?
            @polymorphics << attribute
          elsif attribute.type.match('references').present?
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
        # default options
        options = { references: @references.map(&:name), polymorphics: @polymorphics.map(&:name) }

        # create module model & migration
        unless skip_model
          options[:attributes] = @attributes.select { |a| a.validate_presence == 'true' }.map(&:name)
          create_template 'model.rb', "app/models/#{singular_name}.rb", options
        end

        unless skip_model
          model_associations.select { |ma| ma.association_type == 'belongs_to' }.each do |ma|
            regex = "has_many :#{plural_name}"
            file_path = ma.class_name.present? ? "app/models/#{ma.class_name.underscore}.rb" : "app/models/#{ma.association_name}.rb"
            contents = File.foreach(file_path).grep /#{regex}/
            next if contents.count != 0

            association = "\n\thas_many :#{plural_name}, dependent: :destroy"
            association += "\n\taccepts_nested_attributes_for :#{plural_name}, allow_destroy: true" if ma.accepts_nested_attributes == 'true'
            belongs_to = ma.class_name.present? ? ma.class_name : ma.association_name.classify
            inject_into_file file_path, association, after: /class #{belongs_to} < ApplicationRecord.*/
          end
        end

        create_migration_file 'module_migration.rb', "db/migrate/create_#{plural_name}.rb", force: force if !skip_migration && custom_orm == 'ActiveRecord'
        if custom_orm == 'ActiveRecord'
          model_associations.select { |ma| ma.association_type == 'belongs_to' && ma.counter_cache == 'true' }.uniq { |ma| ma.association_name.classify && ma.class_name }.each do |ma|
            belongs_to = ma.class_name.present? ? ma.class_name.underscore : ma.association_name
            create_migration_file 'counter_cache_migration.rb', "db/migrate/add_#{class_name.pluralize.underscore}_count_to_#{belongs_to.pluralize}.rb", force: force, belongs_to: belongs_to
          end
        end

        # create active serializer & module serializer
        unless skip_serializer
          create_template 'active_serializer.rb', 'app/serializers/active_serializer.rb', skip_if_exist: true
          options[:attributes] = [:id] + @attributes.map(&:name)
          create_template 'serializer.rb', "app/serializers/#{singular_name}_serializer.rb", options
          inject_into_file "app/serializers/#{user_class}_serializer.rb", "\n\tattributes :#{class_name.pluralize.underscore}_count", after: /class #{user_class.classify}Serializer < ActiveSerializer*/ if counter_cache && custom_orm == 'ActiveRecord'
        end
      end

      desc 'Generates controller with the given NAME.'
      def copy_controller_and_spec_files
        template 'controller.rb', "app/controllers/api/#{@wrapper.underscore}/#{controller_path.underscore}.rb" unless skip_controller

        inject_into_file "app/controllers/api/#{@wrapper.underscore}/controllers.rb", "\n\t\t\tmount Api::#{@wrapper.capitalize}::#{controller_path}", after: /Grape::API.*/ unless skip_controller
      end
    end
  end
end
