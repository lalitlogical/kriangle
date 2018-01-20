module API
  module V1
    class <%= controller_class_name %> < Grape::API
      include API::V1::Defaults

      resource :<%= singular_name %>s do
        <% if show_authenticate? -%>
        before do
          authenticate!
        end
        <% end -%>

        description "Return all <%= singular_name %>s"
        params do
          optional :page, type: Integer, desc: "Page number", default: 0
          optional :per_page, type: Integer, desc: "Per Page", default: (PER_PAGE || 15)
        end
        get "", root: :<%= singular_name %>s do
          paginate <%= class_name %>.all
        end

        description "Return a <%= singular_name %>"
        params do
          # requires :id, type: String, desc: "ID of the <%= singular_name %>"
        end
        get ":id", root: "<%= singular_name %>" do
          <%= class_name %>.where(id: permitted_params[:id]).first || raise(CustomError::RecordNotFound, 'Record not found!')
        end

        description "Create a <%= singular_name %>"
        params do
          requires :<%= singular_name %>, type: Hash do
            requires :title, type: String, desc: "Title of the <%= singular_name %>"
            requires :content, type: String, desc: "Content of the <%= singular_name %>"
          end
        end
        post "", root: "<%= singular_name %>" do
          @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
          @<%= singular_name %>.user = @current_user
          if @<%= singular_name %>.save
            @<%= singular_name %>
          else
            error!(@<%= singular_name %>.errors.full_messages, 403)
          end
        end

        description "Update a <%= singular_name %>"
        params do
          # requires :id, type: String, desc: "ID of the <%= singular_name %>"
          requires :<%= singular_name %>, type: Hash do
            requires :title, type: String, desc: "Title of the <%= singular_name %>"
            requires :content, type: String, desc: "Content of the <%= singular_name %>"
            optional :views, type: String, desc: "Content of the <%= singular_name %>"
          end
        end
        post ":id", root: "<%= singular_name %>" do
          <%= singular_name %> = <%= class_name %>.where(id: permitted_params[:id]) || raise(CustomError::RecordNotFound)
          <%= singular_name %>.update(params[:<%= singular_name %>]) if <%= singular_name %>.present?
          <%= singular_name %>
        end

        description "Destoy a <%= singular_name %>"
        params do
          # requires :id, type: String, desc: "ID of the <%= singular_name %>"
        end
        delete ":id", root: "<%= singular_name %>" do
          <%= singular_name %> = <%= class_name %>.where(id: permitted_params[:id]) || raise(CustomError::RecordNotFound)
          <%= singular_name %>.destroy
        end
      end
    end
  end
end
