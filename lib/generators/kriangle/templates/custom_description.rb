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
              required: true
            },
            "X-Client-Id" => {
              description: "Client Id",
              required: true
            },
            "X-Authentication-Token" => {
              description: "Authentication Token",
              required: true
            }
          }
        }
      end
    end
  end
end
