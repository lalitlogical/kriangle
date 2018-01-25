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

          def token
            Digest::MD5.hexdigest(('a'..'z').to_a.sample+(Time.now.to_f * 1000).to_s[1,12]+(rand(10 ** 10).to_s.rjust(10,'0')+rand(10 ** 10).to_s.rjust(10,'0'))[1,15])
          end

          def create_authentication <%= @underscored_name %>, client_id = (ENV['CLIENT_ID'] || token.last(20))
            authentication = <%= @underscored_name %>.authentications.create(client_id: token.last(20), token: token)
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
        <% if options['custom_orm'] == 'ActiveRecord' %>
        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end
        <% elsif options['custom_orm'] == 'Mongoid' %>
        rescue_from Mongoid::Errors::DocumentNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from Mongoid::Errors::InvalidFind do |e|
          error_response(message: e.message, status: 422)
        end
        <% end %>
      end
    end
  end
end
