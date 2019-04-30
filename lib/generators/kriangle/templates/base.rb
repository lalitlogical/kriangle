# frozen_string_literal: true

<%- unless skip_swagger -%>
require 'grape-swagger'
<%- end -%>

module API
  class Base < Grape::API
    mount API::<%= wrapper.capitalize %>::Controllers
    <%- unless skip_swagger -%>

    add_swagger_documentation(
      api_version: "<%= wrapper.underscore %>",
      hide_documentation_path: true,
      mount_path: "/kriangle/api/<%= wrapper.underscore %>/swagger_doc",
      hide_format: true
    )
    <%- end -%>
  end
end
