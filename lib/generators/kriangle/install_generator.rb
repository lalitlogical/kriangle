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

      no_tasks { attr_accessor :scaffold_name, :column_types, :model_attributes, :controller_actions, :wrapper, :custom_orm, :skip_swagger, :skip_avatar, :skip_migration, :skip_authentication }

      # arguments
      argument :user_class, type: :string, default: "User"
      argument :mount_path, type: :string, default: 'Auth'
      argument :args_for_c_m, :type => :array, :default => [], :banner => 'model:attributes'

      class_option :wrapper, type: :string, default: "V1", desc: "Skip \"Swagger UI\""
      class_option :skip_swagger, type: :boolean, default: false, desc: "Skip \"Swagger UI\""
      class_option :skip_avatar, type: :boolean, default: true, desc: "Skip \"Avatar Feature\""
      class_option :skip_migration, :desc => 'Don\'t generate migration file for model.', :type => :boolean
      class_option :custom_orm,   type: :string,  default: "ActiveRecord", desc: "ORM i.e. ActiveRecord, Mongoid"

      source_root File.expand_path('../templates', __FILE__)

      def initialize(*args, &block)
        super
        @model_attributes = []
        @wrapper = options.wrapper
        @custom_orm = options.custom_orm
        @skip_swagger = options.skip_swagger?
        @skip_avatar = options.skip_avatar?
        @skip_migration = options.skip_migration?
        @skip_authentication = false

        args_for_c_m.each do |arg|
          if arg.include?(':')
            @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          end
        end

        if @model_attributes.blank?
          default_attributes = ['first_name:string', 'last_name:string', 'about:text', 'age:integer', 'dob:datetime', 'gender:string']
          @model_attributes = default_attributes.map { |a| Rails::Generators::GeneratedAttribute.new(*a.split(':')) }
        end

        @attributes = [:id, :email]
        @attributes += @model_attributes.map{|a| a.name.to_sym }
      end

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      def copy_initializer
        create_template 'application_record.rb', 'app/models/application_record.rb', skip_if_exist: true
        create_template 'swagger.rb', 'config/initializers/swagger.rb', skip_if_exist: true unless skip_swagger
      end

      def copy_migrations
        if custom_orm == 'ActiveRecord' && !skip_migration
          @underscored_name = user_class.underscore
          create_migration_file "create_users.rb.erb", "db/migrate/create_#{user_class.pluralize.underscore}.rb"
          create_migration_file "create_authentications.rb", "db/migrate/create_authentications.rb"
          create_migration_file "create_avatars.rb", "db/migrate/create_avatars.rb" unless skip_avatar
        end
      end

      def create_model_file
        @underscored_name = user_class.underscore

        create_template "user.rb", "app/models/#{ user_class.underscore }.rb"
        create_template "authentication.rb", "app/models/authentication.rb"
        create_template "avatar.rb", "app/models/avatar.rb" unless skip_avatar

        create_template "active_serializer.rb", "app/serializers/active_serializer.rb", skip_if_exist: true
        create_template "serializer.rb", "app/serializers/#{@underscored_name}_serializer.rb", class_name: user_class, attributes: @attributes
        create_template "serializer.rb", "app/serializers/avatar_serializer.rb", class_name: 'Avatar', attributes: [:id, :image_url] unless skip_avatar

        # Uploader File
        create_template "avatar_uploader.rb", "app/uploaders/avatar_uploader.rb" unless skip_avatar
      end

      desc "Generates required files."
      def copy_controller_and_spec_files
        @underscored_name = user_class.underscore
        @underscored_mount_path = mount_path.underscore

        # Main base files
        create_template "base.rb", "app/controllers/api/base.rb", skip_if_exist: true
        inject_into_file "app/controllers/api/base.rb", "\n\t\t\tmount API::#{wrapper.capitalize}::Controllers", after: /Grape::API.*/

        # All new controllers will go here
        create_template "controllers.rb", "app/controllers/api/#{@wrapper.underscore}/controllers.rb", skip_if_exist: true
        inject_into_file "app/controllers/api/#{@wrapper.underscore}/controllers.rb", "\n\t\t\tmount API::#{@wrapper.capitalize}::#{mount_path.pluralize}", after: /Grape::API.*/

        # Authentications related things will go there
        create_template "defaults.rb", "app/controllers/api/#{@wrapper.underscore}/defaults.rb", skip_if_exist: true
        create_template "custom_description.rb", "app/controllers/api/custom_description.rb"
        create_template "authenticator.rb", "app/controllers/api/authenticator.rb"
        create_template "responder.rb", "app/controllers/api/responder.rb"

        # Authentication i.e. login, register, logout
        template "auth.rb", "app/controllers/api/#{@wrapper.underscore}/#{@underscored_mount_path.pluralize}.rb"

        # setup routes
        inject_into_file "config/routes.rb", "\n\tmount GrapeSwaggerRails::Engine => '/swagger'", after: /routes.draw.*/ unless skip_swagger
        inject_into_file "config/routes.rb", "\n\tmount API::Base, at: '/'", after: /routes.draw.*/
      end
    end
  end
end
