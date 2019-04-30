# frozen_string_literal: true

require 'bcrypt'

module API
  module <%= wrapper.capitalize %>
    module Defaults
      extend ActiveSupport::Concern

      included do
        helpers do
          def logger
            Rails.logger
          end
        end
      end
    end
  end
end
