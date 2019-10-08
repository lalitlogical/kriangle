# frozen_string_literal: true

module Api
  module <%= wrapper.capitalize %>
    class <%= controller_path %> < Grape::API
      include Api::<%= wrapper.capitalize %>::Defaults

      resource :<%= controller_path.underscore %> do
        <%- unless skip_authentication -%>
        include Api::CustomDescription

        before do
          authenticate!
        end
        <%- end -%>
        <%- if resources -%>
          <%- if controller_actions.include?('index') -%>

        <%= description_method_name %> "Return all <%= plural_name %>"
        <%- if !skip_pagination || search_by -%>
        <%- if !reference || (reference && has_many) || @reference_id_param -%>
        params do
          <%- if search_by -%>
          optional :q, type: Hash do
            optional :m, type: String, desc: 'Matching case', default: 'or', values: ['or', 'and'], allow_blank: false
            <%- for attribute in model_attributes.select { |ma| ma.search_by.present? } -%>
            optional :<%= attribute.name %><%= attribute.search_by %>, type: <%= get_attribute_type(attribute.type) %>, desc: "Search by <%= attribute.name.capitalize %>", allow_blank: false
            <%- end -%>
          end
          <%- end -%>
          <%- if @reference_id_param -%>
          requires :<%= @reference_id_param %>, type: Integer, desc: "<%= @user_class %>'s id"
          <%- end -%>
          <%- if !skip_pagination && (!reference || (reference && has_many)) -%>
          optional :page, type: Integer, desc: "Page number", default: 0
          optional :per_page, type: Integer, desc: "Per Page", default: 15
          <%- end -%>
        end
        <%- end -%>
        <%- end -%>
        get "", root: :<%= plural_name %> do
          <%- if reference -%>
            <%- if has_many -%>
              <%- if search_by -%>
          @q = <%= reference_name %>.<%= plural_name %><%= additional_where_clause %>.ransack(params[:q])
          results = @q.result(distinct: true)
              <%- else -%>
          results = <%= reference_name %>.<%= plural_name %><%= additional_where_clause %>
              <%- end -%>
            <%- else -%>
          <%= singular_name %> = <%= reference_name %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
          render_object(<%= singular_name %>)
            <%- end -%>
          <%- else -%>
            <%- if search_by -%>
          @q = <%= class_name %><%= additional_where_clause %>.ransack(params[:q])
          results = @q.result(distinct: true)
            <%- else -%>
          results = <%= class_name %><%= additional_where_clause %>.all
            <%- end -%>
          <%- end -%>
          <%- if !reference || has_many -%>
            <%- if skip_pagination -%>
          render_objects(results)
            <%- else -%>
          render_objects(paginate results)
            <%- end -%>
          <%- end -%>
        end
          <%- end -%>
        <%- end -%>
        <%- if controller_actions.include?('show') -%>

        <%= description_method_name %> "Return a <%= singular_name %>"
        <%- if @reference_id_param -%>
        params do
          requires :<%= @reference_id_param %>, type: Integer, desc: "<%= @user_class %>'s id"
        end
        <%- end -%>
        get ":id", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = <%= reference_name %>.<%= plural_name %>.find(params[:id])
            <%- else -%>
          <%= singular_name %> = <%= reference_name %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
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
            <%- if @reference_id_param -%>
            requires :<%= @reference_id_param %>, type: Integer, desc: "<%= @user_class.classify %>'s id"
            <%- end -%>
            <%- if self_reference -%>
            optional :<%= parent_association_name %>_id, type: Integer, desc: "<%= class_name.classify %>'s id as parent"
            <%- end -%>
            <%- for attribute in model_attributes -%>
            <%= require_or_optional(attribute) %> :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false
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
          <%= singular_name %> = <%= reference_name_create_update %>.<%= plural_name %>.new(params[:<%= singular_name %>])
            <%- else -%>
          <%= singular_name %> = <%= reference_name_create_update %>.<%= singular_name %> || <%= reference_name_create_update %>.build_<%= singular_name %>(params[:<%= singular_name %>])
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
            <%- if @reference_id_param -%>
            requires :<%= @reference_id_param %>, type: Integer, desc: "<%= @user_class %>'s id"
            <%- end -%>
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
          <%= singular_name %> = <%= reference_name_create_update %>.<%= plural_name %>.find(params[:id])
            <%- else -%>
          <%= singular_name %> = <%= reference_name_create_update %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
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

        <%= description_method_name %> "Destroy a <%= singular_name %>"
        <%- if @reference_id_param -%>
        params do
          requires :<%= @reference_id_param %>, type: Integer, desc: "<%= @user_class %>'s id"
        end
        <%- end -%>
        delete ":id", root: "<%= singular_name %>" do
          <%- if reference -%>
            <%- if has_many -%>
          <%= singular_name %> = <%= reference_name %>.<%= plural_name %>.find(params[:id])
            <%- else -%>
          <%= singular_name %> = <%= reference_name %>.<%= singular_name %> || raise(<%= get_record_not_found_exception %>)
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
