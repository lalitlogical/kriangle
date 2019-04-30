module API
  module V1
    class <%= mount_path.pluralize %> < Grape::API
      include API::V1::Defaults
      include API::Responder

      resource :<%= @underscored_mount_path.pluralize %> do
        include API::CustomDescription

        desc "Register new <%= @underscored_name %>"
        params do
          requires :<%= @underscored_name %>, type: Hash do
            requires :email, type: String, desc: "Email address", allow_blank: false
            requires :password, type: String, desc: "Password", allow_blank: false
            requires :password_confirmation, type: String, desc: "Password Confirmation", allow_blank: false
            # Additional(optional) parameters
            <%- for attribute in model_attributes -%>
              <%- if attribute.name == 'gender' -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false, default: 'Male', values: ['Male', 'Female', 'Other']
              <%- else -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false
              <%- end -%>
            <%- end -%>
          end
        end
        post :register do
          <%= @underscored_name %> = <%= user_class %>.new(params[:<%= @underscored_name %>])
          if <%= @underscored_name %>.save
            create_authentication(<%= @underscored_name %>)
            render_object(<%= @underscored_name %>, additional_response: { message: "You have registered successfully." })
          else
            json_error_response({ errors: <%= @underscored_name %>.errors.full_messages })
          end
        end

        desc "Creates and returns <%= @underscored_name %> with access token if valid login"
        params do
          requires :<%= @underscored_name %>, type: Hash do
            requires :email, type: String, desc: "Email address", allow_blank: false
            requires :password, type: String, desc: "Password", allow_blank: false
          end
        end
        post :login do
          <%= @underscored_name %> = <%= user_class %>.find_by(email: params[:<%= @underscored_name %>][:email].downcase)
          if <%= @underscored_name %> && <%= @underscored_name %>.valid_password?(params[:<%= @underscored_name %>][:password])
            create_authentication(<%= @underscored_name %>)
            render_object(<%= @underscored_name %>, additional_response: { message: "You have successfully logged in." })
          else
            json_error_response({ errors: ['Invalid email or password.'] }, 401)
          end
        end

        description "Logout <%= @underscored_name %>"
        post :logout do
          destroy_authentication_token
          json_success_response(message: "You have successfully logout.")
        end

        description "Return pong if logged in correctly"
        get :ping do
          authenticate!
          json_success_response(message: "pong")
        end

        desc "Forgot Password"
        params do
          requires :<%= @underscored_name %>, type: Hash do
            requires :email, type: String, desc: "Email address", allow_blank: false
          end
        end
        post :forgot_password do
          <%= @underscored_name %> = <%= user_class %>.find_by(email: params[:<%= @underscored_name %>][:email].downcase)
          if <%= @underscored_name %>.present?
            <%= @underscored_name %>.update(reset_token: token)
            # send Forgot Password email
            json_success_response(message: "You will receive email with instructions to reset password shortly.")
          else
            json_error_response({ errors: ['Invalid email address.'] })
          end
        end

        desc "Reset Password"
        params do
          requires :reset_token, type: String, desc: "Reset Password", allow_blank: false
          requires :<%= @underscored_name %>, type: Hash do
            requires :password, type: String, desc: "Password", allow_blank: false
            requires :password_confirmation, type: String, desc: "Password Confirmation", allow_blank: false
          end
        end
        post :reset_password do
          <%= @underscored_name %> = <%= user_class %>.find_by(reset_token: params[:reset_token])
          if <%= @underscored_name %>.update(params[:<%= @underscored_name %>])
            # send Reset Password email
            json_success_response(message: "Your password have successfully changed.")
          else
            json_error_response({ errors: ['Invalid reset token.'] })
          end
        end

        description "Return <%= @underscored_name %>"
        get '' do
          authenticate!
          render_object(current_<%= @underscored_name %>)
        end

        description "Update <%= @underscored_name %>"
        params do
          requires :<%= @underscored_name %>, type: Hash do
            # Additional(optional) parameters
            <%- for attribute in model_attributes -%>
              <%- if attribute.name == 'gender' -%>
            optional :<%= attribute.name %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false, default: 'Male', values: ['Male', 'Female', 'Other']
              <%- else -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", allow_blank: false
              <%- end -%>
            <%- end -%>
            # group :avatars_attributes, type: Hash, desc: "An array of avatars" do
            #   optional :id, type: Integer
            #   optional :image, type: String
            #   optional :_destroy, type: Boolean
            # end
          end
        end
        put "" do
          authenticate!
          if current_<%= @underscored_name %>.update(params[:<%= @underscored_name %>])
            render_object(current_<%= @underscored_name %>)
          else
            json_error_response({ errors: current_<%= @underscored_name %>.errors.full_messages })
          end
        end
      end
    end
  end
end
