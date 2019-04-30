# frozen_string_literal: true

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
  module Responder
    extend ActiveSupport::Concern

    included do
      # catch exception and return JSON-formatted error
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

      helpers do
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
          extract_options(objects.to_a, options, true) # extract required options

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

        def render_unprocessable_entity(errors)
          render_error_response(errors, 422) and return
        end

        def render_unauthorized_access
          render_error_response(['Invalid or expired token.'], 401) and return
        end

        def render_error_response(errors = [], status = 422)
          json_error_response({ errors: errors }, status)
        end

        def json_success_response response = {}
          JsonResponse.new(response.merge(status: true)).as_json
        end

        def json_error_response response = {}, status = 422
          error!(JsonResponse.new(response.merge(status: true)).as_json, status)
        end

        def array_serializer
          ActiveModel::Serializer::CollectionSerializer
        end

        def single_serializer
          ActiveModelSerializers::SerializableResource
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
