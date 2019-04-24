# frozen_string_literal: true

class <%= class_name %> < ApplicationRecord
  <%- if custom_orm == 'Mongoid' -%>
  include Mongoid::Document
  include Mongoid::Timestamps

  # Add your fields below
  # field :title, type: String
  # field :content, type: String, default: ""
  # field :views, type: Integer, default: 0
  <%- end -%>
  <%- if reference -%>
  belongs_to :<%= user_class %>
  <%- end -%>
  <%- for parent_model in @options[:belongs_to] -%>
  belongs_to :<%= parent_model %>
  <%- end -%>

  # Some validation
  # validates :name, :description, presence: true
end
