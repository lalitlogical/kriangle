# frozen_string_literal: true

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

        # Authenticator and Responder
        <%- unless skip_authentication -%>
        include API::Authenticator
        <%- end -%>
        include API::Responder

        helpers do
          def logger
            Rails.logger
          end
        end
      end
    end
  end
end
