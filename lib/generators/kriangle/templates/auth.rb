# frozen_string_literal: true

module Api
  module <%= wrapper.capitalize %>
    class <%= controller_path %> < Grape::API
      include Api::<%= wrapper.capitalize %>::Defaults

      resource :<%= controller_path.underscore %> do
        include Api::CustomDescription

        desc "Register new <%= underscored_user_class %>"
        params do
          requires :<%= underscored_user_class %>, type: Hash do
            requires :email, type: String, desc: "Email address"
            requires :password, type: String, desc: "Password"
            requires :password_confirmation, type: String, desc: "Password Confirmation"
            # Additional(optional) parameters
            <%- for attribute in model_attributes -%>
              <%- if attribute.name == 'gender' -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", default: 'Male', values: ['Male', 'Female', 'Other']
              <%- else -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>"
              <%- end -%>
            <%- end -%>
          end
        end
        post :register do
          <%= underscored_user_class %> = <%= user_class %>.new(params[:<%= underscored_user_class %>])
          if <%= underscored_user_class %>.save
            create_authentication(<%= underscored_user_class %>)
            render_object(<%= underscored_user_class %>, additional_response: { message: "You have registered successfully." })
          else
            json_error_response({ errors: <%= underscored_user_class %>.errors.full_messages })
          end
        end

        desc "Creates and returns <%= underscored_user_class %> with access token if valid login"
        params do
          requires :<%= underscored_user_class %>, type: Hash do
            requires :email, type: String, desc: "Email address"
            requires :password, type: String, desc: "Password"
          end
        end
        post :login do
          <%= underscored_user_class %> = <%= user_class %>.find_by(email: params[:<%= underscored_user_class %>][:email].downcase)
          if <%= underscored_user_class %> && <%= underscored_user_class %>.valid_password?(params[:<%= underscored_user_class %>][:password])
            create_authentication(<%= underscored_user_class %>)
            render_object(<%= underscored_user_class %>, additional_response: { message: "You have successfully logged in." })
          else
            json_error_response({ errors: ['Invalid email or password.'] }, 401)
          end
        end

        description "Logout <%= underscored_user_class %>"
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
          requires :<%= underscored_user_class %>, type: Hash do
            requires :email, type: String, desc: "Email address"
          end
        end
        post :forgot_password do
          <%= underscored_user_class %> = <%= user_class %>.find_by(email: params[:<%= underscored_user_class %>][:email].downcase)
          if <%= underscored_user_class %>.present?
            <%= underscored_user_class %>.update(reset_token: token)
            # send Forgot Password email
            json_success_response(message: "You will receive email with instructions to reset password shortly.")
          else
            json_error_response({ errors: ['Invalid email address.'] })
          end
        end

        desc "Reset Password"
        params do
          requires :reset_token, type: String, desc: "Reset Password"
          requires :<%= underscored_user_class %>, type: Hash do
            requires :password, type: String, desc: "Password"
            requires :password_confirmation, type: String, desc: "Password Confirmation"
          end
        end
        post :reset_password do
          <%= underscored_user_class %> = <%= user_class %>.find_by(reset_token: params[:reset_token])
          if <%= underscored_user_class %>.update(params[:<%= underscored_user_class %>])
            # send Reset Password email
            json_success_response(message: "Your password have successfully changed.")
          else
            json_error_response({ errors: ['Invalid reset token.'] })
          end
        end

        description "Return <%= underscored_user_class %>"
        get '' do
          authenticate!
          render_object(current_<%= underscored_user_class %>)
        end

        description "Update <%= underscored_user_class %>"
        params do
          requires :<%= underscored_user_class %>, type: Hash do
            # Additional(optional) parameters
            <%- for attribute in model_attributes -%>
              <%- if attribute.name == 'gender' -%>
            optional :<%= attribute.name %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>", default: 'Male', values: ['Male', 'Female', 'Other']
              <%- else -%>
            optional :<%= get_attribute_name(attribute.name, attribute.type) %>, type: <%= get_attribute_type(attribute.type) %>, desc: "<%= attribute.name.capitalize %>"
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
          if current_<%= underscored_user_class %>.update(params[:<%= underscored_user_class %>])
            render_object(current_<%= underscored_user_class %>)
          else
            json_error_response({ errors: current_<%= underscored_user_class %>.errors.full_messages })
          end
        end
      end
    end
  end
end
