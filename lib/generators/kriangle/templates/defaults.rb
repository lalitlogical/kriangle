module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json
        formatter :json, Grape::Formatter::ActiveModelSerializers

        def self.description title
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

        helpers do
          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def logger
            Rails.logger
          end

          def generate_client_id
            "#{SecureRandom.urlsafe_base64}#{DateTime.now.to_i}#{SecureRandom.urlsafe_base64}"
          end

          def generate_token
            string = ''
            (1..5).each{ |i| string += "#{SecureRandom.urlsafe_base64}#{DateTime.now.to_i}#{SecureRandom.urlsafe_base64}#{ i == rand(1..6) ? '.' : ''}" }
            string.gsub('.','')
          end

          def create_authentication <%= @underscored_name %>, client_id = (ENV['CLIENT_ID'] || generate_client_id)
            authentication = <%= @underscored_name %>.authentications.create(client_id: client_id, token: generate_token)
            header 'X-Uid', authentication.user_id
            header 'X-Client-Id', authentication.client_id
            header 'X-Authentication-Token', authentication.token
          end

          def get_authentication_token
            headers['X-Authentication-Token'] or return
            Authentication.where(user_id: headers['X-Uid'], client_id: headers['X-Client-Id'], token: headers['X-Authentication-Token']).first
          end

          def destroy_authentication_token
            authentication = get_authentication_token
            authentication.destroy if authentication.present?
          end

          def get_current_<%= @underscored_name %>
            authentication = get_authentication_token
            authentication ? authentication.<%= @underscored_name %> : nil
          end

          def current_<%= @underscored_name %>
            @current_<%= @underscored_name %> ||= get_current_<%= @underscored_name %>
          end

          def authenticate!
            unless current_<%= @underscored_name %>
              error!({
                success: false,
                errors: ['Invalid or expired token.']
              }, 401)
            end
          end

          def array_serializer
            ActiveModel::Serializer::CollectionSerializer
          end

          def single_serializer
            ActiveModelSerializers::SerializableResource
          end

          def json_success_response response = {}, status_code = 200
            { success: true }.merge(response)
          end

          def json_error_response response = {}, status_code = (ENV['STATUS_CODE'] || 422)
            error!({ success: false }.merge(response), status_code)
          end
        end

        rescue_from <%= get_record_not_found_exception %> do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from <%= get_record_invalid_exception %> do |e|
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end
