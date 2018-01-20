module API
  module V1
    class <%= name.pluralize %> < Grape::API
      include API::V1::Defaults

      resource :<%= @underscored_name.pluralize %> do
        desc "Register new <%= @underscored_name %>"
        params do
          requires :<%= @underscored_name %>, type: Hash do
            requires :first_name, type: String, desc: "First Name", allow_blank: false
            optional :last_name, type: String, desc: "Last Name"
            requires :email, type: String, desc: "Email address", allow_blank: false
            requires :password, type: String, desc: "Password", allow_blank: false
            requires :password_confirmation, type: String, desc: "Password Confirmation", allow_blank: false
          end
        end
        post :register do
          @<%= @underscored_name %> = <%= name %>.new(params[:<%= @underscored_name %>])
          if @<%= @underscored_name %>.save
            create_authentication(@<%= @underscored_name %>)
            @<%= @underscored_name %>
          else
            error!(@<%= @underscored_name %>.errors.full_messages, 403)
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
          <%= @underscored_name %> = <%= name %>.find_by(email: params[:<%= @underscored_name %>][:email].downcase)
          if <%= @underscored_name %> && <%= @underscored_name %>.valid_password?(params[:<%= @underscored_name %>][:password])
            create_authentication(<%= @underscored_name %>)
            <%= @underscored_name %>
          else
            error!('Invalid email or password.', 401)
          end
        end

        description "Logout <%= @underscored_name %>"
        post :logout do
          destroy_authentication_token
          { message: "You have successfully logout." }
        end

        description "Returns pong if logged in correctly"
        get :ping do
          authenticate!
          { message: "pong" }
        end

        desc "Forgot Password"
        params do
          requires :<%= @underscored_name %>, type: Hash do
            requires :email, type: String, desc: "Email address", allow_blank: false
          end
        end
        post :forgot_password do
          <%= @underscored_name %> = <%= name %>.find_by(email: params[:<%= @underscored_name %>][:email].downcase)
          if <%= @underscored_name %>.present?
            <%= @underscored_name %>.update(reset_token: token)
            # send Forgot Password email
            { message: "You will receive email with instructions to reset password shortly." }
          else
            error!('Invalid email.', 422)
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
          <%= @underscored_name %> = <%= name %>.find_by(reset_token: params[:reset_token])
          if <%= @underscored_name %>.update(params[:<%= @underscored_name %>])
            # send Reset Password email
            { message: "Your password have successfully changed." }
          else
            error!('Invalid reset token.', 422)
          end
        end
      end
    end
  end
end
