# frozen_string_literal: true

class <%= @class_name %>Serializer < ActiveSerializer
  attributes <%= @options[:attributes].present? ? @options[:attributes].to_s.gsub(/\[|\]/, '') : ':id' %>
  <%- for parent_model in @options[:belongs_to] -%>
  
  belongs_to :<%= parent_model %>
  <%- end -%>

  # has_one :address
  # has_many :avatars

  # def custom_function
  #   some logic goes here
  # end
end
