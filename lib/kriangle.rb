# frozen_string_literal: true

require 'kriangle/version'

require 'bcrypt'
require 'devise'
require 'dotenv-rails'

require 'grape'
require 'grape-active_model_serializers'
require 'grape-rails-cache'
require 'grape-swagger'
require 'grape-swagger-rails'

require 'api-pagination'
require 'kaminari'

require 'carrierwave'

module Kriangle
  # database for which migration files created
  mattr_accessor :database
  @@database = 'sqlite3'

  # Custom ORM, default 'ActiveRecord'
  # mattr_accessor :custom_orm
  # @@custom_orm = 'ActiveRecord'

  # Default way to set up Kriangle. Run rails generate install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end
end
