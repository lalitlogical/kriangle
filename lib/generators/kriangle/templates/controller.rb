# frozen_string_literal: true

module Api
  module <%= wrapper.capitalize %>
    class <%= controller_class_name %> < Grape::API
      include Api::<%= wrapper.capitalize %>::Defaults

      resource :<%= plural_name %> do
        <%- unless skip_authentication -%>
        include Api::CustomDescription

        before do
          authenticate!
        end

        <%- end -%>
        <%- if resources -%>
          <%- if controller_actions.include?('index') -%>
        <%= description_method_name %> "Return all <%= plural_name %>"
        <%- unless skip_pagination -%>
        <%- if !reference or (reference && has_many) -%>
        params do
          optional :page, type: Integer, desc: "Page number", default: 0
          optional :per_page, type: Integer, desc: "Per Page", default: 15
        end
        <%- end -%>
        <%- end -%>
        get "", root: :<%= plural_name %> do
          <%- if reference -%>
            <%- if has_many -%>
              <%- if skip_pagination -%>
          results = current_<%= user_class %>.<%= plural_name %>
              <%- else -%>
          results = paginate current_<%= user_class %>.<%= plural_name %>
              <%- end -%>
          render_objects(results)
            <%- else -%>
          <%= singular_name %> = current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
          render_object(<%= singular_name %>)
            <%- end -%>
          <%- else -%>
          <%- if skip_pagination -%>
          results = <%= class_name %>.all
          <%- else -%>
          results = paginate <%= class_name %>.all
          <%- end -%>
          render_objects(results)
          <%- end -%>
        end
          <%- end -%>
        <%- end -%>
        <%- if controller_actions.include?('show') -%>

        <%= description_method_name %> "Return a <%= singular_name %>"
        get ":id", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = current_<%= user_class %>.<%= plural_name %>.find(params[:id])
            <%- else -%>
          <%= singular_name %> = current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
            <%- end -%>
          <%- else -%>
          <%= singular_name %> = <%= class_name %>.find(params[:id])
          <%- end -%>
          render_object(<%= singular_name %>)
        end
        <%- end -%>
        <%- if controller_actions.include?('create') -%>

        <%= description_method_name %> "Create a <%= singular_name %>"
        params do
          requires :<%= singular_name %>, type: Hash do
            <%- for attribute in model_attributes -%>
            requires :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false
            <%- end -%>
            <%- unless skip_tips -%>
            # requires :title, type: String, desc: "Title of the <%= singular_name %>"
            # requires :content, type: String, desc: "Content of the <%= singular_name %>"
            <%- end -%>
          end
        end
        post "", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = current_<%= user_class %>.<%= plural_name %>.new(params[:<%= singular_name %>])
            <%- else -%>
          <%= singular_name %> = current_<%= user_class %>.<%= singular_name %> || current_<%= user_class %>.build_<%= singular_name %>(params[:<%= singular_name %>])
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

        <%= description_method_name %> "Update a <%= singular_name %>"
        params do
          requires :<%= singular_name %>, type: Hash do
            <%- for attribute in model_attributes -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false
            <%- end -%>
            <%- unless skip_tips -%>
            # requires :title, type: String, desc: "Title of the <%= singular_name %>"
            # requires :content, type: String, desc: "Content of the <%= singular_name %>"
            # optional :views, type: String, desc: "Content of the <%= singular_name %>"
            <%- end -%>
          end
        end
        put ":id", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = current_<%= user_class %>.<%= plural_name %>.find(params[:id])
            <%- else -%>
          <%= singular_name %> = current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
            <%- end -%>
          <%- else -%>
          <%= singular_name %> = <%= class_name %>.find(params[:id])
          <%- end -%>
          if <%= singular_name %>.update(params[:<%= singular_name %>])
            render_object(<%= singular_name %>, additional_response: { message: "<%= class_name %> updated successfully." })
          else
            json_error_response(errors: <%= singular_name %>.errors.full_messages)
          end
        end
        <%- end -%>
        <%- if controller_actions.include?('destroy') -%>

        <%= description_method_name %> "Destoy a <%= singular_name %>"
        delete ":id", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = current_<%= user_class %>.<%= plural_name %>.find(params[:id])
            <%- else -%>
          <%= singular_name %> = current_<%= user_class %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
            <%- end -%>
          <%- else -%>
          <%= singular_name %> = <%= class_name %>.find(params[:id])
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
