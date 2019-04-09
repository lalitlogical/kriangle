module API
  module V1
    class <%= controller_class_name %> < Grape::API
      include API::V1::Defaults

      resource :<%= singular_name %>s do
        <%- unless skip_authentication -%>
        before do
          authenticate!
        end
        <%- end -%>
        <%- if resources -%>
          <%- if controller_actions.include?('index') -%>

        desc "Return all <%= singular_name %>s"
        <%- if !reference or (reference && has_many) -%>
        params do
          optional :page, type: Integer, desc: "Page number", default: 0
          optional :per_page, type: Integer, desc: "Per Page", default: 15
        end
        <%- end -%>
        get "", root: :<%= singular_name %>s do
          <%- if reference -%>
            <%- if has_many -%>
          results = paginate @current_<%= user_class %>.<%= singular_name %>s
          render_objects(results)
            <%- else -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
          render_object(<%= singular_name %>)
            <%- end -%>
          <%- else -%>
          results = paginate <%= class_name %>.all
          render_objects(results)
          <%- end -%>
        end
          <%- end -%>
        <%- end -%>
        <%- if controller_actions.include?('show') -%>

        desc "Return a <%= singular_name %>"
        get ":id", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %>s.find(id: params[:id])
            <%- else -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
            <%- end -%>
          <%- else -%>
          <%= singular_name %> = <%= class_name %>.find(id: params[:id])
          <%- end -%>
          render_object(<%= singular_name %>)
        end
        <%- end -%>
        <%- if controller_actions.include?('create') -%>

        desc "Create a <%= singular_name %>"
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
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %>s.new(params[:<%= singular_name %>])
            <%- else -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %> || @current_<%= user_class %>.build_<%= singular_name %>(params[:<%= singular_name %>])
          <%= singular_name %>.attributes = params[:<%= singular_name %>] if <%= singular_name %>.persisted?
            <%- end -%>
          <%- else -%>
          <%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
          <%- end -%>
          if <%= singular_name %>.save
            render_object(<%= singular_name %>, additional_response: { message: "<%= class_name %> created successfully." })
          else
            json_error_response(errors: <%= singular_name %>.errors.full_messages)
          end
        end
        <%- end -%>
        <%- if controller_actions.include?('update') -%>

        desc "Update a <%= singular_name %>"
        params do
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
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %>s.find(id: params[:id])
            <%- else -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
            <%- end -%>
          <%- else -%>
          <%= singular_name %> = <%= class_name %>.find(id: params[:id])
          <%- end -%>
          if <%= singular_name %>.update(params[:<%= singular_name %>])
            render_object(<%= singular_name %>, additional_response: { message: "<%= class_name %> updated successfully." })
          else
            json_error_response(errors: <%= singular_name %>.errors.full_messages)
          end
        end
        <%- end -%>
        <%- if controller_actions.include?('destroy') -%>

        desc "Destoy a <%= singular_name %>"
        delete ":id", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %>s.find(id: params[:id])
            <%- else -%>
          <%= singular_name %> = @current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
            <%- end -%>
          <%- else -%>
          <%= singular_name %> = <%= class_name %>.find(id: params[:id])
          <%- end -%>
          if <%= singular_name %>.destroy
            json_success_response(message: "<%= class_name %> destroyed successfully.")
          else
            json_error_response(errors: <%= singular_name %>.errors.full_messages)
          end
        end
        <%- end -%>
      end
    end
  end
end
