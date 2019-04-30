# frozen_string_literal: true

require 'bcrypt'

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

        helpers do
          # Catch exception and return JSON-formatted error
          def handle_exceptions
            begin
              yield
            rescue <%= get_record_not_found_exception %> => e
              status_code = 404
            rescue <%= get_record_invalid_exception %> => e
              json_error_response(e.record) && return
            rescue ArgumentError => e
              status_code = 400
            rescue StandardError => e
              status_code = 500
            end
            json_error_response({ message: e.class.to_s, errors: [{ detail: e.message, trace: e.backtrace }] }, status_code) unless e.class == NilClass
          end

          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def logger
            Rails.logger
          end

          def generate_random_string
            "#{SecureRandom.urlsafe_base64}#{DateTime.now.to_i}#{SecureRandom.urlsafe_base64}"
          end

          def create_authentication(<%= @underscored_name %>, client_id = ENV['CLIENT_ID'])
            # delete all old tokens if any present
            <%= @underscored_name %>.authentications.delete_all

            # create new auth token
            client_id ||= SecureRandom.urlsafe_base64(nil, false)
            token = generate_random_string
            authentication = <%= @underscored_name %>.authentications.create(client_id: client_id, token: BCrypt::Password.create(token))

            # build auth header
            header 'X-Uid', authentication.<%= @underscored_name %>_id
            header 'X-Client-Id', authentication.client_id
            header 'X-Authentication-Token', token
          end

          def authentication
            # user has already been found and authenticated
            return @authentication if @authentication

            # get details from header or params
            uid = headers['X-Uid'] || params['uid']
            @token     ||= headers['X-Authentication-Token'] || params['access-token']
            @client_id ||= request.headers['X-Client-Id'] || params['client-id']

            # client_id isn't required, set to 'default' if absent
            @client_id ||= 'default'

            # ensure we clear the client_id
            unless @token
              @client_id = nil
              return
            end

            return unless @token

            auth = Authentication.where(<%= @underscored_name %>_id: uid, client_id: @client_id).last || return
            return @authentication = auth if ::BCrypt::Password.new(auth.token) == @token

            @authentication = nil
          end

          def destroy_authentication_token
            authentication&.destroy
          end

          def current_<%= @underscored_name %>
            @current_<%= @underscored_name %> ||= authentication&.<%= @underscored_name %>
          end

          def authenticate!
            render_unauthorized_access && return unless current_<%= @underscored_name %>
          end
        end

        rescue_from <%= get_record_not_found_exception %> do |e|
          message = e.try(:problem) || e.try(:message)
          model_name = message.match(/(?<=class|find)[^w]+/)&.to_s&.strip
          render_error_response(["No #{model_name || 'Record'} Found."], status: 404)
        end

        rescue_from <%= get_record_invalid_exception %> do |e|
          render_error_response([e.message], status: 422)
        end
      end
    end
  end
end
