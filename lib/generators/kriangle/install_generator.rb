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

      no_tasks { attr_accessor :scaffold_name, :column_types, :model_attributes, :controller_actions, :custom_orm, :skip_swagger }

      # arguments
      argument :user_class, type: :string, default: "User"
      argument :mount_path, type: :string, default: 'Auth'
      argument :args_for_c_m, :type => :array, :default => [], :banner => 'model:attributes'

      class_option :skip_swagger, type: :boolean, default: false, desc: "Skip \"Swagger UI\""
      class_option :custom_orm,   type: :string,  default: "ActiveRecord", desc: "ORM i.e. ActiveRecord, mongoid"

      source_root File.expand_path('../templates', __FILE__)

      def initialize(*args, &block)
        super
        @model_attributes = []
        @custom_orm = options.custom_orm
        @skip_swagger = options.skip_swagger?

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
        create_template 'application_record.rb', 'app/models/application_record.rb'
        create_template 'swagger.rb', 'config/initializers/swagger.rb' unless skip_swagger
      end

      def copy_migrations
        if custom_orm == 'ActiveRecord'
          @underscored_name = user_class.underscore
          if self.class.migration_exists?("db/migrate", "create_#{user_class.pluralize.underscore}")
            say_status("skipped", "Migration 'create_#{user_class.pluralize.underscore}' already exists")
          else
            migration_template "create_users.rb.erb", "db/migrate/create_#{user_class.pluralize.underscore}.rb"
          end

          if self.class.migration_exists?("db/migrate", "create_authentications")
            say_status("skipped", "Migration 'create_authentications' already exists")
          else
            migration_template "create_authentications.rb", "db/migrate/create_authentications.rb"
          end

          if self.class.migration_exists?("db/migrate", "create_avatars")
            say_status("skipped", "Migration 'creat_avatars' already exists")
          else
            migration_template "create_avatars.rb", "db/migrate/create_avatars.rb"
          end
        end
      end

      def create_model_file
        @underscored_name = user_class.underscore

        create_template "user.rb", "app/models/#{ user_class.underscore }.rb"
        create_template "authentication.rb", "app/models/authentication.rb"
        create_template "avatar.rb", "app/models/avatar.rb"

        create_template "active_serializer.rb", "app/serializers/active_serializer.rb"
        @class_name = user_class
        create_template "serializer.rb", "app/serializers/#{@underscored_name}_serializer.rb", @attributes
        @class_name = 'Avatar'
        create_template "serializer.rb", "app/serializers/avatar_serializer.rb", [:id, :image_url]

        # Uploader File
        create_template "avatar_uploader.rb", "app/uploaders/avatar_uploader.rb"
      end

      desc "Generates required files."
      def copy_controller_and_spec_files
        @underscored_name = user_class.underscore
        @underscored_mount_path = mount_path.underscore

        # Main base files
        create_template "base.rb", "app/controllers/api/base.rb"

        # All new controllers will go here
        create_template "controllers.rb", "app/controllers/api/v1/controllers.rb"

        # Authentications related things will go there
        template "defaults.rb", "app/controllers/api/v1/defaults.rb"

        # Authentication i.e. login, register, logout
        template "auth.rb", "app/controllers/api/v1/#{@underscored_mount_path.pluralize}.rb"

        # setup routes
        inject_into_file "config/routes.rb", "\n\tmount GrapeSwaggerRails::Engine => '/swagger'", after: /routes.draw.*/ unless skip_swagger
        inject_into_file "config/routes.rb", "\n\tmount API::Base, at: '/'", after: /routes.draw.*/
      end
    end
  end
end
