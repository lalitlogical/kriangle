# frozen_string_literal: true

GrapeSwaggerRails.options.app_name = 'Rest APIs with Kriangle'
GrapeSwaggerRails.options.url      = "/kriangle/api/<%= wrapper.underscore %>/swagger_doc.json"
GrapeSwaggerRails.options.before_action do
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
end
GrapeSwaggerRails.options.doc_expansion = 'list'
