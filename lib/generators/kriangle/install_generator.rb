require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'
require 'generators/kriangle/generator_helpers'

module Kriangle
  module Generators
    # Custom scaffolding generator
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      include Kriangle::Generators::GeneratorHelpers
      argument :name, type: :string, default: "User"
      class_option :skip_swagger, type: :boolean, default: false, desc: "Skip \"Swagger UI\""
      class_option :custom_orm, type: :string, default: "ActiveRecord", desc: "ORM i.e. ActiveRecord, mongoid"

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
        template 'application_record.rb', 'app/models/application_record.rb'
        template 'swagger.rb', 'config/initializers/swagger.rb' unless options['skip_swagger']
      end

      def create_model_file
        @underscored_name = name.underscore.gsub('/', '_')
        # @pluralize_name = name.underscore.pluralize
        # template "model.rb", "app/models/#{@underscored_name}.rb"
        # # migration_template "create_#{@pluralize_name}.rb", "db/migrate/create_#{@pluralize_name}.rb" if options['custom_orm'] == 'ActiveRecord'

        template "authentication.rb", "app/models/authentication.rb"
        migration_template "create_authentications.rb", "db/migrate/create_authentications.rb" if options['custom_orm'] == 'ActiveRecord'
      end

      desc "Generates required files."
      def copy_controller_and_spec_files
        @underscored_name = name.underscore.gsub('/', '_')
        # Main base file
        template "base.rb", "app/controllers/api/base.rb"
        template "defaults.rb", "app/controllers/api/v1/defaults.rb"

        # All new controllers will go here
        template "controllers.rb", "app/controllers/api/v1/controllers.rb"

        # Authentication file
        template "users.rb", "app/controllers/api/v1/#{name.underscore.pluralize}.rb"

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
