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
      class_option :skip_migration, type: :boolean, default: true, desc: "Skip Migration"

      source_root File.expand_path('../templates', __FILE__)

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_initializer
        template 'application_record.rb', 'app/models/application_record.rb'
        template 'swagger.rb', 'config/initializers/swagger.rb' unless options['skip_swagger']
      end

      def copy_migrations
        @underscored_name = user_class.underscore
        migration_template "create_authentications.rb", "db/migrate/create_authentications.rb" if !options['skip_migration'] && options['custom_orm'] == 'ActiveRecord'
      end

      def create_model_file
        @underscored_name = user_class.underscore
        @underscored_mount_path = mount_path.underscore

        # @pluralize_name = user_class.underscore.pluralize
        # template "model.rb", "app/models/#{@underscored_name}.rb"
        # # migration_template "create_#{@pluralize_name}.rb", "db/migrate/create_#{@pluralize_name}.rb" if options['custom_orm'] == 'ActiveRecord'

        template "authentication.rb", "app/models/authentication.rb"
        template "user_serializer.rb", "app/serializers/#{@underscored_name}_serializer.rb"
      end

      desc "Generates required files."
      def copy_controller_and_spec_files
        @underscored_name = user_class.underscore
        @underscored_mount_path = mount_path.underscore

        # Main base file
        template "base.rb", "app/controllers/api/base.rb"
        template "defaults.rb", "app/controllers/api/v1/defaults.rb"

        # Authentication file
        template "auth.rb", "app/controllers/api/v1/#{@underscored_mount_path.pluralize}.rb"

        # All new controllers will go here
        template "controllers.rb", "app/controllers/api/v1/controllers.rb"

        # setup routes
        inject_into_file "config/routes.rb", "\n\tmount GrapeSwaggerRails::Engine => '/swagger'", after: /routes.draw.*/ unless options['skip_swagger']
        inject_into_file "config/routes.rb", "\n\tmount API::Base, at: '/'", after: /routes.draw.*/
      end
    end

    # def add_routes    #   inject_into_file "config/routes.rb", "\n\t\tmount GrapeSwaggerRails::Engine => '/swagger'", after: /routes.draw.*/ unless options['skip_swagger']
    #   inject_into_file "config/routes.rb", "\n mount API::Base, at: '/'", after: /routes.draw.*/
    #
    #   routes_string = options['skip_swagger'] ? '' : "mount GrapeSwaggerRails::Engine => '/swagger'"
    #   routes_string += '\n mount API::Base, at: "/"'
    #   route routes_string
    # end
  end
end
