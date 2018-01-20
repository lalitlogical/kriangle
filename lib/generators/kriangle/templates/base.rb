<% unless options['skip_swagger'] -%>
require 'grape-swagger'
<% end -%>
module API
  class Base < Grape::API
    mount API::V1::Controllers
    <% unless options['skip_swagger'] -%>

      add_swagger_documentation(
        api_version: "v1",
        hide_documentation_path: true,
        mount_path: "/kriangle/api/v1/swagger_doc",
        hide_format: true
      )
    <% end -%>

  end
end
