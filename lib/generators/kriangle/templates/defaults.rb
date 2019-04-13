class JsonResponse
  attr_reader :success, :message, :data, :meta, :errors

  def initialize(options = {})
    @success = options[:success].to_s.empty? ? true : options[:success]
    @message = options[:message] || options[:errors].try(:first) || ''
    @data = options[:data] || []
    @meta = options[:meta] || {}
    @errors = options[:errors] || []
  end

  def as_json(*)
    {
      success: success,
      message: message,
      data: data,
      meta: meta,
      errors: errors
    }
  end
end

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

          # extract options
          # i.e. serializer = nil, options = {}, additional_response = {}
          def extract_options resource, options, collection = false
            # identify serializer
            @serializer = options[:serializer]
            unless @serializer
              if collection
                class_name = resource&.first&.class
                if class_name.present? && class_name != NilClass
                  @serializer = "#{class_name}Serializer".constantize
                end
              else
                @serializer = "#{resource.class}Serializer".constantize
              end
            end

            # additional params
            @additional_response = options[:additional_response] || {}
          end

          # render single object with serializer
          def render_object object, **options
            extract_options(object, options) # extract required options

            json_success_response({
              data: @serializer.present? ? single_serializer.new(object, serializer: @serializer) : {},
            }.merge(@additional_response))
          end

          def format_aggregation(aggs)
            return [] if aggs.blank?
            
            aggregations = []
            aggs.each do |k, value|
              value['buckets'].each do |bucket|
                bucket['count'] = bucket.delete('doc_count')
              end
              aggregations << { name: k, buckets: value['buckets'] }
            end
            aggregations
          end

          # render collection of objects with serializer
          def render_objects objects, **options
            extract_options(objects, options, true) # extract required options

            # collect meta data if any present there
            meta = {}
            meta.merge!(options[:extra_params]) if options[:extra_params].present?
            meta[:suggestions]  = objects.suggestions if objects.respond_to?(:suggestions) && objects.suggestions.present?
            meta[:aggregations] = format_aggregation(objects.aggs) if objects.respond_to?(:aggs)
            if objects.respond_to?(:total_count)
              meta[:pagination] = {
                total_count: objects.total_count,
                current_page: objects.current_page,
                next_page: objects.next_page,
                per_page: objects.try(:per_page) || objects.try(:limit_value) || 10000
              }
            end

            # send data & meta
            json_success_response({
              data: @serializer.present? ? array_serializer.new(objects, serializer: @serializer) : [],
              meta: meta
            }.merge(@additional_response))
          end

          def render_not_found(resource)
            render_error_response(["#{ resource } not found."], :not_found)
          end

          def render_logout
            render_error_response([I18n.t('devise.failure.unauthenticated')], :unauthorized)
          end

          def render_errors(object)
            render_error_response(object.errors, :unprocessable_entity)
          end

          def render_error
            render_error_response(['Something went wrong. Please try after sometime.'], :unprocessable_entity)
          end

          def render_interval_server_error
            render_error_response(['Internal server error.'], 500)
          end

          # json success response
          def json_success_response response = {}, status = 200
            render_json_response({ success: true }.merge(response), status)
          end

          # json error response
          def json_error_response response = {}, status = (ENV['STATUS_CODE'] || 422)
            render_json_response({ success: false }.merge(response), status)
          end

          def render_response(success = true, message = "", errors = [], status = 200)
            render_json_response({
              success: success,
              message: message,
              errors: errors
            }, status)
          end

          def render_success_response(message = "", status = 200)
            render_json_response({
              success: true,
              message: message
            }, status)
          end

          def render_error_response(errors = [], status = 422)
            render_json_response({
              success: false,
              errors: errors
            }, status)
          end

          def render_unprocessable_entity(errors)
            render_json_response({
              success: false,
              errors: errors
            }, 422) and return true
          end

          def render_unauthorized_response
            render_json_response({
              success: false,
              errors: [I18n.t('devise.failure.invalid', { authentication_keys: 'Email' })]
            }, 401) and return
          end

          def render_unauthorized_access
            render_json_response({
              success: false,
              errors: [I18n.t('devise.failure.unauthenticated')]
            }, 401) and return
          end

          def render_json_response(options = {}, status = 500)
            render json: JsonResponse.new(options), status: status
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
          message = e.try(:problem) || e.try(:message)
          model_name = message.match(/(?<=class|find)[^w]+/)&.to_s&.strip
          json_error_response(errors: ["No #{model_name || 'Record'} Found."], status: 404)
        end

        rescue_from <%= get_record_invalid_exception %> do |e|
          json_error_response(errors: [e.message], status: 422)
        end
      end
    end
  end
end
