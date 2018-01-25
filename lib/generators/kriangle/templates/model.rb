class <%= class_name %> < ApplicationRecord
  <% if options['custom_orm'] == 'Mongoid' %>
  include Mongoid::Document
  include Mongoid::Timestamps

  # Add your fields below
  # field :title, type: String
  # field :content, type: String, default: ""
  # field :views, type: Integer, default: 0
  <% end %>

  # Some validation
  # validates :name, :description, presence: true
end
