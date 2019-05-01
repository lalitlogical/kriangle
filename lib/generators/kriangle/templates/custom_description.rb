# frozen_string_literal: true

module API
  module CustomDescription
    extend ActiveSupport::Concern

    class_methods do
      def description title
        desc title, {
          headers: {
            "X-Uid" => {
              description: "User Id",
              required: true,
              default: ENV['X_UID']
            },
            "X-Client-Id" => {
              description: "Client Id",
              required: true,
              default: ENV['X_CLIENT_ID']
            },
            "X-Authentication-Token" => {
              description: "Authentication Token",
              required: true,
              default: ENV['X_AUTH_TOKEN']
            }
          }
        }
      end
    end
  end
end
