# frozen_string_literal: true

class <%= @class_name %>Serializer < ActiveSerializer
  attributes <%= @options[:attributes].present? ? @options[:attributes].to_s.gsub(/\[|\]/, '') : ':id' %>
  
  <%- @options[:belongs_to].try(:each) do |parent_model| -%>
  belongs_to :<%= parent_model %>
  <%- end -%>

  # belongs_to :user
  # has_one :address
  # has_many :avatars

  # def custom_function
  #   some logic goes here
  # end
end
