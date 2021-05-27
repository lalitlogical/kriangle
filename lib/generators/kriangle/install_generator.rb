# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'
require 'generators/kriangle/generator_helpers'

module Kriangle
  module Generators
    # Custom scaffolding generator
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      include Kriangle::Generators::GeneratorHelpers

      no_tasks do
        attr_accessor :underscored_user_class,
                      :column_types,
                      :model_attributes,
                      :model_associations,
                      :controller_actions,
                      :wrapper,
                      :controller_path,
                      :custom_orm,
                      :self_reference,
                      :skip_tips,
                      :skip_swagger,
                      :skip_avatar,
                      :skip_migration,
                      :skip_authentication,
                      :database
      end

      # arguments
      argument :user_class, type: :string, default: 'User'
      # argument :mount_path, type: :string, default: 'User'
      argument :args_for_c_m, type: :array, default: [], banner: 'model:attributes'

      class_option :database, type: :string, default: 'sqlite3', desc: "database i.e. postgresql, mysql, sqlite3"

      class_option :wrapper, type: :string, default: 'V1', desc: 'Skip "Swagger UI"'
      class_option :controller_path, type: :string, desc: "controller's path"
      class_option :skip_tips, type: :boolean, default: false, desc: 'Skip "Tips from different files i.e. model, serializer, etc."'
      class_option :skip_swagger, type: :boolean, default: false, desc: 'Skip "Swagger UI"'
      class_option :skip_avatar, type: :boolean, default: true, desc: 'Skip "Avatar Feature"'
      class_option :skip_migration, desc: 'Don\'t generate migration file for model.', type: :boolean, default: false
      class_option :custom_orm, type: :string, default: 'ActiveRecord', desc: 'ORM i.e. ActiveRecord, Mongoid'

      source_root File.expand_path('templates', __dir__)

      def initialize(*args, &block)
        super
        @model_attributes = []
        @model_associations = []
        @underscored_user_class = user_class.underscore
        @wrapper = options.wrapper
        @database = options.database
        @custom_orm = 'ActiveRecord' # Kriangle.custom_orm
        @skip_tips = options.skip_tips?
        @skip_swagger = options.skip_swagger?
        @skip_avatar = options.skip_avatar?
        @skip_migration = options.skip_migration?
        @skip_authentication = false
        @controller_path = options.controller_path&.classify&.pluralize || user_class.classify&.pluralize

        args_for_c_m.each do |arg|
          next unless arg.include?(':')

          options = arg.split(':')
          if arg.match(/^ma:/).present?
            options.shift
            @model_associations << Association.new(*options)
          else
            @model_attributes << Attribute.new(*options)
          end
        end

        if @model_attributes.blank?
          default_attributes = ['first_name:string', 'last_name:string', 'about:text', 'age:integer', 'dob:datetime', 'gender:string']
          @model_attributes = default_attributes.map { |arg| Attribute.new(*arg.split(':')) }
        end
        @model_attributes.uniq!(&:name)

        @attributes = %i[id email]
        @attributes += @model_attributes.map { |a| a.name.to_sym }
        @attributes.uniq!
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
        create_template 'kriangle.rb', 'config/initializers/kriangle.rb', skip_if_exist: true
        create_template 'application_record.rb', 'app/models/application_record.rb', skip_if_exist: true
        create_template 'swagger.rb', 'config/initializers/swagger.rb', skip_if_exist: true unless skip_swagger
      end

      def copy_migrations
        if custom_orm == 'ActiveRecord' && !skip_migration
          create_migration_file 'create_users.rb.erb', "db/migrate/create_#{user_class.pluralize.underscore}.rb"
          create_migration_file 'create_authentications.rb', 'db/migrate/create_authentications.rb'
          create_migration_file 'create_avatars.rb', 'db/migrate/create_avatars.rb' unless skip_avatar
        end
      end

      def create_model_file
        create_template 'user.rb', "app/models/#{user_class.underscore}.rb"
        create_template 'authentication.rb', 'app/models/authentication.rb'
        create_template 'avatar.rb', 'app/models/avatar.rb' unless skip_avatar

        create_template 'active_serializer.rb', 'app/serializers/active_serializer.rb', skip_if_exist: true
        create_template 'serializer.rb', "app/serializers/#{underscored_user_class}_serializer.rb", class_name: user_class, attributes: @attributes
        create_template 'serializer.rb', 'app/serializers/avatar_serializer.rb', class_name: 'Avatar', attributes: %i[id image_url] unless skip_avatar

        # Uploader File
        create_template 'avatar_uploader.rb', 'app/uploaders/avatar_uploader.rb' unless skip_avatar
      end

      desc 'Generates required files.'
      def copy_controller_and_spec_files
        # Main base files
        create_template 'base.rb', 'app/controllers/api/base.rb', skip_if_exist: true
        inject_into_file 'app/controllers/api/base.rb', "\n\t\t\tmount Api::#{wrapper.capitalize}::Controllers", after: /Grape::API.*/

        # All new controllers will go here
        create_template 'controllers.rb', "app/controllers/api/#{@wrapper.underscore}/controllers.rb", skip_if_exist: true
        inject_into_file "app/controllers/api/#{@wrapper.underscore}/controllers.rb", "\n\t\t\tmount Api::#{@wrapper.capitalize}::#{controller_path}", after: /Grape::API.*/

        # Authentications related things will go there
        create_template 'defaults.rb', "app/controllers/api/#{@wrapper.underscore}/defaults.rb", skip_if_exist: true
        create_template 'custom_description.rb', 'app/controllers/api/custom_description.rb'
        create_template 'authenticator.rb', 'app/controllers/api/authenticator.rb'
        create_template 'responder.rb', 'app/controllers/api/responder.rb'

        # Authentication i.e. login, register, logout
        template 'auth.rb', "app/controllers/api/#{@wrapper.underscore}/#{controller_path.underscore}.rb"

        # setup routes
        inject_into_file 'config/routes.rb', "\n\tmount GrapeSwaggerRails::Engine => '/swagger'", after: /routes.draw.*/ unless skip_swagger
        inject_into_file 'config/routes.rb', "\n\tmount Api::Base, at: '/'", after: /routes.draw.*/
      end
    end
  end
end
