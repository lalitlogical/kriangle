# frozen_string_literal: true

require 'bcrypt'

module Api
  module Authenticator
    extend ActiveSupport::Concern

    included do
      helpers do
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
    end
  end
end
