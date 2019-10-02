# frozen_string_literal: true

class <%= user_class %> < ApplicationRecord
  <% if custom_orm == 'Mongoid' %>
  include Mongoid::Document
  include Mongoid::Timestamps

  # Add your fields below
  # field :title, type: String
  # field :content, type: String, default: ""
  # field :views, type: Integer, default: 0
  <% end %>

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  <%- unless skip_avatar -%>
  has_many :avatars
  <%- end -%>
  has_many :authentications

  # Some validation
  # validates :first_name, presence: true
end
