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

      # arguments
      argument :user_class, type: :string, default: "User"
      argument :mount_path, type: :string, default: 'Auth'

      class_option :skip_swagger, type: :boolean, default: false, desc: "Skip \"Swagger UI\""
      class_option :custom_orm,   type: :string,  default: "ActiveRecord", desc: "ORM i.e. ActiveRecord, mongoid"

      source_root File.expand_path('../templates', __FILE__)

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
        create_template 'swagger.rb', 'config/initializers/swagger.rb' unless options['skip_swagger']
      end

      def copy_migrations
        if options['custom_orm'] == 'ActiveRecord'
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
        create_template "serializer.rb", "app/serializers/#{@underscored_name}_serializer.rb", ":id, :first_name, :last_name, :email, :age, :gender, :dob, :about"
        @class_name = 'Avatar'
        create_template "serializer.rb", "app/serializers/avatar_serializer.rb", ":id, :image_url"

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
        inject_into_file "config/routes.rb", "\n\tmount GrapeSwaggerRails::Engine => '/swagger'", after: /routes.draw.*/ unless options['skip_swagger']
        inject_into_file "config/routes.rb", "\n\tmount API::Base, at: '/'", after: /routes.draw.*/
      end
    end
  end
end
