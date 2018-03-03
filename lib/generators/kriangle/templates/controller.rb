module API
  module V1
    class <%= controller_class_name %> < Grape::API
      include API::V1::Defaults

      resource :<%= singular_name %>s do
        <%- if show_authenticate? -%>
        before do
          authenticate!
        end
        <%- end -%>

        <%- if controller_actions.include?('index') -%>
        description "Return all <%= singular_name %>s"
        params do
          optional :page, type: Integer, desc: "Page number", default: 0
          optional :per_page, type: Integer, desc: "Per Page", default: 15
        end
        get "", root: :<%= singular_name %>s do
          paginate <%= class_name %>.all
        end
        <%- end -%>
        <%- if controller_actions.include?('show') -%>

        description "Return a <%= singular_name %>"
        params do
          # requires :id, type: String, desc: "ID of the <%= singular_name %>"
        end
        get ":id", root: "<%= singular_name %>" do
          <%= singular_name %> = <%= class_name %>.where(id: params[:id]).first || raise(<%= get_record_not_found_exception %>, 'Record not found!')
          json_success_response({
            data: single_serializer.new(<%= singular_name %>, serializer: <%= class_name %>Serializer)
          })
        end
        <%- end -%>
        <%- if controller_actions.include?('create') -%>

        description "Create a <%= singular_name %>"
        params do
          requires :<%= singular_name %>, type: Hash do
            <%- for attribute in model_attributes -%>
            requires :<%= get_attribute_name(attribute.name, attribute.type)  %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false
            <%- end -%>
            # requires :title, type: String, desc: "Title of the <%= singular_name %>"
            # requires :content, type: String, desc: "Content of the <%= singular_name %>"
          end
        end
        post "", root: "<%= singular_name %>" do
          <%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
          <%- if options['reference'] -%>
          <%= singular_name %>.user = @current_user
          <%- end -%>
          if <%= singular_name %>.save
            json_success_response({
              message: "<%= class_name %> created successfully.",
              data: single_serializer.new(<%= singular_name %>, serializer: <%= class_name %>Serializer)
            })
          else
            json_error_response({
              errors: <%= singular_name %>.errors.full_messages
            })
          end
        end
        <%- end -%>
        <%- if controller_actions.include?('update') -%>

        description "Update a <%= singular_name %>"
        params do
          # requires :id, type: String, desc: "ID of the <%= singular_name %>"
          requires :<%= singular_name %>, type: Hash do
            <%- for attribute in model_attributes -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type)  %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false
            <%- end -%>
            # requires :title, type: String, desc: "Title of the <%= singular_name %>"
            # requires :content, type: String, desc: "Content of the <%= singular_name %>"
            # optional :views, type: String, desc: "Content of the <%= singular_name %>"
          end
        end
        post ":id", root: "<%= singular_name %>" do
          <%= singular_name %> = <%= class_name %>.where(id: params[:id]).first || raise(<%= get_record_not_found_exception %>)
          if <%= singular_name %>.update(params[:<%= singular_name %>])
            json_success_response({
              message: "<%= class_name %> updated successfully.",
              data: single_serializer.new(<%= singular_name %>, serializer: <%= class_name %>Serializer)
            })
          else
            json_error_response({
              errors: <%= singular_name %>.errors.full_messages
            })
          end
        end
        <%- end -%>
        <%- if controller_actions.include?('destroy') -%>

        description "Destoy a <%= singular_name %>"
        params do
          # requires :id, type: String, desc: "ID of the <%= singular_name %>"
        end
        delete ":id", root: "<%= singular_name %>" do
          <%= singular_name %> = <%= class_name %>.where(id: params[:id]).first || raise(<%= get_record_not_found_exception %>)
          if <%= singular_name %>.destroy
            json_success_response({
              message: "<%= class_name %> destroyed successfully.",
              data: {}
            })
          else
            json_error_response({
              errors: <%= singular_name %>.errors.full_messages
            })
          end
        end
        <%- end -%>
      end
    end
  end
end
