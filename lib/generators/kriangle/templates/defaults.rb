# frozen_string_literal: true

require 'bcrypt'

module API
  module <%= wrapper.capitalize %>
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "<%= wrapper.underscore %>", using: :path
        default_format :json
        format :json
        formatter :json, Grape::Formatter::ActiveModelSerializers
        
        helpers do
          def logger
            Rails.logger
          end
        end
      end
    end
  end
end
